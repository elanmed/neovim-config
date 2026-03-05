local curr_indices = nil
local head_lines = nil

vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWritePost", }, {
  group = vim.api.nvim_create_augroup("DiffTracker", { clear = true, }),
  callback = require "helpers".async(function(ev)
    local curr_bufnr = vim.api.nvim_get_current_buf()
    if ev.buf ~= curr_bufnr then return end

    local worktree_lines = vim.api.nvim_buf_get_lines(curr_bufnr, 0, -1, false)
    local worktree_str = table.concat(worktree_lines, "\n")

    local curr_bufname = vim.fs.relpath(vim.fn.getcwd(), vim.api.nvim_buf_get_name(curr_bufnr))
    --- @type vim.SystemCompleted
    local out = require "helpers".await(function(resolve)
      vim.system({ "git", "show", "HEAD:" .. curr_bufname, }, resolve)
    end)

    if out.code ~= 0 then return end
    if out.stdout == nil then return end
    local head_str = out.stdout
    assert(head_str ~= nil)

    head_str = head_str:gsub("\n$", "") .. "\n"
    head_lines = vim.split(head_str, "\n", { trimempty = true, })
    worktree_str = worktree_str:gsub("\n$", "") .. "\n"

    curr_indices = vim.text.diff(head_str, worktree_str, { result_type = "indices", })
  end),
})

--- @param type 'next' | 'prev'
local function navigate_hunk(type)
  if curr_indices == nil then
    return require "helpers".notify.error "`curr_indices` is nil"
  end
  local row_1i = vim.api.nvim_win_get_cursor(0)[1]

  local next_hunk_row_1i = nil
  local indices = (function()
    if type == "next" then return curr_indices end
    return require "helpers".tbl.reverse(curr_indices)
  end)()

  for _, hunk in ipairs(indices) do
    local _, _, start_worktree_1i, _ = unpack(hunk)
    if type == "next" then
      if start_worktree_1i > row_1i then
        next_hunk_row_1i = start_worktree_1i
        break
      end
    else
      if start_worktree_1i < row_1i then
        next_hunk_row_1i = start_worktree_1i
        break
      end
    end
  end

  if next_hunk_row_1i == nil then
    return require "helpers".notify.error(("No %s hunk"):format(type))
  end

  vim.api.nvim_win_set_cursor(0, { next_hunk_row_1i, 0, })
end

vim.keymap.set("n", "]c", function() navigate_hunk "next" end, { desc = "Navigate to the next hunk", })
vim.keymap.set("n", "[c", function() navigate_hunk "prev" end, { desc = "Navigate to the prev hunk", })

vim.keymap.set("n", "gh", function()
  local row_1i = vim.api.nvim_win_get_cursor(0)[1]
  for _, hunk in ipairs(curr_indices) do
    local start_head_1i, count_head, start_worktree_1i, count_worktree = unpack(hunk)

    local start_worktree_0i = start_worktree_1i - 1
    local end_worktree_1i_excl = start_worktree_1i + count_worktree
    local end_worktree_0i_excl = end_worktree_1i_excl - 1
    local end_worktree_1i_incl = end_worktree_1i_excl - 1

    local end_head_1i_excl = start_head_1i + count_head
    local end_head_1i_incl = end_head_1i_excl - 1

    vim.print { start_head_1i = start_head_1i, count_head = count_head, start_worktree_1i = start_worktree_1i, count_worktree = count_worktree, }

    local is_deletion = count_worktree == 0
    local in_deletion_range = is_deletion and row_1i == start_worktree_1i
    local in_insertion_change_range = not is_deletion and row_1i >= start_worktree_1i and row_1i <= end_worktree_1i_incl

    if in_deletion_range or in_insertion_change_range then
      local head_chunk = vim.list_slice(head_lines, start_head_1i, end_head_1i_incl)
      vim.api.nvim_buf_set_lines(0, start_worktree_0i, end_worktree_0i_excl, true, head_chunk)
      return
    end
  end

  return require "helpers".notify.error "No hunk"
end, { desc = "Reset the hunk on the current line", })

vim.keymap.set("n", "<C-b>", function()
  if vim.bo.buftype ~= "" then
    return require "helpers".notify.error "buftype is not normal"
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

  local out = vim.system { "git", "show", "HEAD:" .. curr_bufname, }:wait()
  local stdout = (function()
    if out.code ~= 0 then return "" end
    if out.stdout == nil then return "" end
    return out.stdout
  end)()
  head_lines = vim.split(stdout, "\n", { trimempty = true, })

  vim.api.nvim_buf_set_lines(head_bufnr, 0, -1, false, head_lines)
  vim.api.nvim_buf_set_lines(worktree_bufnr, 0, -1, false, worktree_lines)

  local apply_syntax_highlighting = function()
    local lang = vim.treesitter.language.get_lang(curr_filetype)
    vim.treesitter.start(0, lang)
  end

  vim.api.nvim_buf_call(head_bufnr, apply_syntax_highlighting)
  vim.api.nvim_buf_call(worktree_bufnr, apply_syntax_highlighting)

  for _, bufnr in ipairs { worktree_bufnr, head_bufnr, } do
    vim.keymap.set("n", "<C-b>", function()
      local cursor = vim.api.nvim_win_get_cursor(0)
      vim.cmd.tabclose()
      vim.api.nvim_win_set_cursor(0, cursor)
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

  vim.wo[worktree_winnr].winbar = "Worktree"
  vim.wo[head_winnr].winbar = "HEAD"

  vim.api.nvim_win_call(head_winnr, vim.cmd.diffthis)
  vim.api.nvim_win_call(worktree_winnr, vim.cmd.diffthis)
end)
