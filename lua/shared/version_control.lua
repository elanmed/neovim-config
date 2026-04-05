local h = require "helpers"
local buffer_state = {}

local ns_id = vim.api.nvim_create_namespace "GitDiff"

--- @param bufnr number
--- @param resolve Resolve
local function update_state_for_buf(bufnr, resolve)
  h.async(function()
    if not vim.api.nvim_buf_is_valid(bufnr) then return resolve() end
    local bufname = vim.fs.relpath(vim.fn.getcwd(), vim.api.nvim_buf_get_name(bufnr))
    if bufname == nil then return resolve() end

    local worktree_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local worktree_str = table.concat(worktree_lines, "\n")

    local out = h.await(function(inner_resolve)
      vim.system({ "git", "show", ":" .. bufname, }, inner_resolve)
    end)
    if out.code ~= 0 then return resolve() end
    local head_str = out.stdout
    if head_str == nil then return resolve() end

    head_str = head_str:gsub("\n$", "") .. "\n"
    local head_lines = vim.split(head_str, "\n", { trimempty = true, })
    local wt_str = worktree_str:gsub("\n$", "") .. "\n"

    local indices = vim.text.diff(head_str, wt_str, { result_type = "indices", })
    buffer_state[bufnr] = {
      indices = indices,
      head_lines = head_lines,
    }
    resolve()
  end)()
end

local update_signs = vim.schedule_wrap(function()
  local curr_bufnr = vim.api.nvim_get_current_buf()
  local state = buffer_state[curr_bufnr]

  if state == nil then
    return
  end

  local rows_to_hl = {}
  for _, raw_hunk in ipairs(state.indices) do
    local hunk = require "helpers".diff.unpack_hunk(raw_hunk)

    local hunk_hl_group = (function()
      if hunk.is_deletion then return "DiffSignDelete" end
      if hunk.is_insertion then return "DiffSignAdd" end
      return "DiffSignChange"
    end)()

    for row_1i = hunk.start_new_1i, math.max(hunk.end_new_1i_incl, hunk.start_new_1i) do
      local row_0i = row_1i - 1
      if row_0i >= 0 then
        table.insert(rows_to_hl, { row_0i = row_0i, hl = hunk_hl_group, })
      end
    end
  end

  vim.api.nvim_buf_clear_namespace(curr_bufnr, ns_id, 0, -1)
  for _, row_to_hl in ipairs(rows_to_hl) do
    vim.api.nvim_buf_set_extmark(curr_bufnr, ns_id, row_to_hl.row_0i, 0, {
      number_hl_group = row_to_hl.hl,
    })
  end
end)

local timer = nil
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", }, {
  group = vim.api.nvim_create_augroup("DiffTrackerTextEvents", { clear = true, }),
  callback = function(event)
    if timer then vim.fn.timer_stop(timer) end

    timer = vim.fn.timer_start(300, h.async(function()
      if event.buf ~= vim.api.nvim_get_current_buf() then return end
      h.await(function(resolve) update_state_for_buf(event.buf, resolve) end)
      update_signs()
    end))
  end,
})

vim.api.nvim_create_autocmd({ "BufWinEnter", "BufEnter", "BufWritePost", }, {
  group = vim.api.nvim_create_augroup("DiffTrackerBufEvents", { clear = true, }),
  callback = h.async(function(event)
    if event.buf ~= vim.api.nvim_get_current_buf() then return end
    h.await(function(resolve) update_state_for_buf(event.buf, resolve) end)
    update_signs()
  end),
})

vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("DiffTrackerIndexEvents", { clear = true, }),
  pattern = { "GitIndexChanged", },
  callback = h.async(function()
    local bufs = {}
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.bo[bufnr].buftype == "" and vim.api.nvim_buf_is_loaded(bufnr) then
        table.insert(bufs, bufnr)
      end
    end

    for _, bufnr in ipairs(bufs) do
      h.await(function(resolve) update_state_for_buf(bufnr, resolve) end)
    end
    update_signs()
  end),
})

vim.api.nvim_create_autocmd("BufDelete", {
  group = vim.api.nvim_create_augroup("DiffTrackerCleanup", { clear = true, }),
  callback = function(event)
    buffer_state[event.buf] = nil
  end,
})

--- @param direction 'next' | 'prev'
local function navigate_hunk(direction)
  local curr_bufnr = vim.api.nvim_get_current_buf()
  local state = buffer_state[curr_bufnr]

  if state == nil then
    return vim.notify("Missing diff state for this buffer", vim.log.levels.ERROR)
  end

  local indices = (function()
    if direction == "next" then return state.indices end
    return require "helpers".tbl.reverse(state.indices)
  end)()

  if #indices == 0 then
    return vim.notify("No hunks", vim.log.levels.ERROR)
  end

  local row_1i = vim.api.nvim_win_get_cursor(0)[1]
  local next_hunk_row_1i = nil

  for _, raw_hunk in ipairs(indices) do
    local hunk = require "helpers".diff.unpack_hunk(raw_hunk)
    if direction == "next" then
      if hunk.start_new_1i > row_1i then
        next_hunk_row_1i = hunk.start_new_1i
        break
      end
    else
      if hunk.start_new_1i < row_1i then
        next_hunk_row_1i = hunk.start_new_1i
        break
      end
    end
  end

  if next_hunk_row_1i == nil then
    if direction == "next" then
      local hunk = require "helpers".diff.unpack_hunk(indices[1])
      vim.api.nvim_win_set_cursor(0, { hunk.start_new_1i, 0, })
      return vim.notify("Wrapping to the first hunk", vim.log.levels.INFO)
    else
      local hunk = require "helpers".diff.unpack_hunk(indices[#indices])
      vim.api.nvim_win_set_cursor(0, { hunk.start_new_1i, 0, })
      return vim.notify("Wrapping to the last hunk", vim.log.levels.INFO)
    end
  end

  vim.api.nvim_win_set_cursor(0, { next_hunk_row_1i, 0, })
end

vim.keymap.set("n", "]c", function() navigate_hunk "next" end, { desc = "Navigate to the next hunk", })
vim.keymap.set("n", "[c", function() navigate_hunk "prev" end, { desc = "Navigate to the prev hunk", })

vim.keymap.set("n", "gh", function()
  local curr_bufnr = vim.api.nvim_get_current_buf()
  local state = buffer_state[curr_bufnr]
  if state == nil then
    return vim.notify("Missing diff state for this buffer", vim.log.levels.ERROR)
  end

  local row_1i = vim.api.nvim_win_get_cursor(0)[1]
  for _, raw_hunk in ipairs(state.indices) do
    local hunk = require "helpers".diff.unpack_hunk(raw_hunk)

    local head_chunk = vim.list_slice(state.head_lines, hunk.start_old_1i, hunk.end_old_1i_incl)
    if hunk.is_deletion then
      if row_1i == hunk.start_new_1i then
        local insert_after_0i = hunk.start_new_0i + 1
        vim.api.nvim_buf_set_lines(curr_bufnr, insert_after_0i, insert_after_0i, true, head_chunk)
        return vim.notify(("Inserting at line %s"):format(insert_after_0i), vim.log.levels.INFO)
      end
    elseif row_1i >= hunk.start_new_1i and row_1i <= hunk.end_new_1i_incl then
      vim.api.nvim_buf_set_lines(curr_bufnr, hunk.start_new_0i, hunk.end_new_0i_excl, true, head_chunk)
      return vim.notify(("Resetting lines %s to %s"):format(hunk.start_new_1i, hunk.end_new_1i_incl), vim.log.levels
        .INFO)
    end
  end

  return vim.notify("No hunk", vim.log.levels.ERROR)
end, { desc = "Reset the hunk on the current line", })

vim.keymap.set("n", "<C-b>", function()
  if vim.bo.buftype ~= "" then
    return vim.notify("buftype is not normal", vim.log.levels.ERROR)
  end

  local curr_cursor = vim.api.nvim_win_get_cursor(0)
  local curr_bufnr = vim.api.nvim_get_current_buf()
  local curr_bufname = vim.fs.relpath(vim.fn.getcwd(), vim.api.nvim_buf_get_name(curr_bufnr))

  local curr_filetype = vim.bo.filetype
  local worktree_lines = vim.api.nvim_buf_get_lines(curr_bufnr, 0, -1, false)

  vim.cmd.tabnew()
  local head_winnr = vim.api.nvim_tabpage_get_win(0)
  local head_bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(head_bufnr)

  local worktree_bufnr = vim.api.nvim_create_buf(false, true)
  local worktree_winnr = vim.api.nvim_open_win(worktree_bufnr, true, {
    split = "right",
    win = 0,
  })

  local out = vim.system { "git", "show", ":" .. curr_bufname, }:wait()
  local stdout = (function()
    if out.code ~= 0 then return "" end
    if out.stdout == nil then return "" end
    return out.stdout
  end)()
  local head_lines = vim.split(stdout, "\n", { trimempty = true, })

  vim.api.nvim_buf_set_lines(head_bufnr, 0, -1, false, head_lines)
  vim.api.nvim_buf_set_lines(worktree_bufnr, 0, -1, false, worktree_lines)

  vim.bo[head_bufnr].filetype = curr_filetype
  vim.bo[worktree_bufnr].filetype = curr_filetype

  for _, bufnr in ipairs { worktree_bufnr, head_bufnr, } do
    vim.keymap.set("n", "<C-b>", function()
      local cursor = vim.api.nvim_win_get_cursor(0)
      vim.cmd.tabclose()
      vim.api.nvim_set_current_buf(curr_bufnr)
      local clamped = math.min(cursor[1], #worktree_lines)
      vim.api.nvim_win_set_cursor(0, { clamped, cursor[2], })
    end, { buffer = bufnr, })

    vim.keymap.set("n", "<C-^>", "<Nop>", { buffer = bufnr, })
    vim.keymap.set("n", "<C-o>", "<Nop>", { buffer = bufnr, })
    vim.keymap.set("n", "<C-i>", "<Nop>", { buffer = bufnr, })
    vim.keymap.set("n", "<leader>d", "<Nop>", { buffer = bufnr, })
    vim.keymap.set("n", "<leader>q", "<Nop>", { buffer = bufnr, })
    vim.keymap.set("n", "<leader>e", "<Nop>", { buffer = bufnr, })
  end

  pcall(vim.api.nvim_win_set_cursor, head_winnr, curr_cursor)
  vim.api.nvim_win_set_cursor(worktree_winnr, curr_cursor)

  vim.bo[worktree_bufnr].modifiable = false
  vim.bo[head_bufnr].modifiable = false

  vim.bo[head_bufnr].bufhidden = "wipe"
  vim.bo[worktree_bufnr].bufhidden = "wipe"

  vim.wo[worktree_winnr].winbar = "Worktree"
  vim.wo[head_winnr].winbar = "HEAD"

  vim.api.nvim_win_call(head_winnr, vim.cmd.diffthis)
  vim.api.nvim_win_call(worktree_winnr, vim.cmd.diffthis)
end)

vim.system({ "git", "rev-parse", "--absolute-git-dir", }, {}, function(result)
  if result.code ~= 0 then return end
  local git_dir = vim.trim(result.stdout)

  local index_watch = vim.uv.new_fs_event()
  if index_watch == nil then return end

  index_watch:start(git_dir, {}, function(_, filename)
    vim.schedule(function()
      if filename == "index" then
        vim.api.nvim_exec_autocmds("User", { pattern = "GitIndexChanged", })
      elseif filename == "HEAD" then
        vim.api.nvim_exec_autocmds("User", { pattern = "GitHeadChanged", })
      end
    end)
  end)
end)

