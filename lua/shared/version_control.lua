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

