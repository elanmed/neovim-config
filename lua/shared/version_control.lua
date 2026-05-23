local noop_keymaps = { "<C-^>", "<C-o>", "<C-i>", "<leader>d", "<leader>q", "<leader>e", }

vim.keymap.set("n", "<C-b>", function()
  if vim.t.diff_view then
    local worktree_bufnr = vim.t.worktree_bufnr
    local cursor = vim.api.nvim_win_get_cursor(0)
    for _, keymap in ipairs(noop_keymaps) do
      pcall(vim.api.nvim_buf_del_keymap, worktree_bufnr, "n", keymap)
    end
    vim.cmd.tabclose()
    vim.api.nvim_set_current_buf(worktree_bufnr)
    local line_count = vim.api.nvim_buf_line_count(worktree_bufnr)
    local clamped = math.min(cursor[1], line_count)
    vim.api.nvim_win_set_cursor(0, { clamped, cursor[2], })
    return
  end

  if vim.bo.buftype ~= "" then
    return vim.notify("buftype is not normal", vim.log.levels.ERROR)
  end

  local worktree_bufnr = vim.api.nvim_get_current_buf()

  local curr_cursor = vim.api.nvim_win_get_cursor(0)
  local cwd = vim.uv.cwd()
  assert(cwd ~= nil)
  local curr_bufname = vim.fs.relpath(cwd, vim.api.nvim_buf_get_name(worktree_bufnr))
  if curr_bufname == nil then
    return vim.notify("relpath is nil", vim.log.levels.WARN)
  end

  local curr_filetype = vim.bo.filetype
  vim.cmd.tabnew()
  local tab_worktree_winnr = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(tab_worktree_winnr, worktree_bufnr)

  vim.t.diff_view = true
  vim.t.worktree_bufnr = worktree_bufnr

  local head_bufnr = vim.api.nvim_create_buf(false, true)
  local head_winnr = vim.api.nvim_open_win(head_bufnr, true, {
    split = "left",
    win = tab_worktree_winnr,
  })

  local out = vim.system { "git", "show", ":" .. curr_bufname, }:wait()
  local stdout = (function()
    if out.code ~= 0 then return "" end
    if out.stdout == nil then return "" end
    return out.stdout
  end)()
  local head_lines = vim.split(stdout, "\n", { trimempty = true, })

  vim.api.nvim_buf_set_lines(head_bufnr, 0, -1, false, head_lines)

  vim.bo[head_bufnr].filetype = curr_filetype

  for _, bufnr in ipairs { worktree_bufnr, head_bufnr, } do
    for _, keymap in ipairs(noop_keymaps) do
      vim.keymap.set("n", keymap, "<Nop>", { buffer = bufnr, })
    end
  end

  pcall(vim.api.nvim_win_set_cursor, head_winnr, curr_cursor)
  vim.api.nvim_win_set_cursor(tab_worktree_winnr, curr_cursor)

  vim.bo[head_bufnr].modifiable = false
  vim.bo[head_bufnr].bufhidden = "wipe"

  vim.wo[head_winnr].winbar = "HEAD"
  vim.wo[tab_worktree_winnr].winbar = "Worktree"

  vim.api.nvim_win_call(head_winnr, vim.cmd.diffthis)
  vim.api.nvim_win_call(tab_worktree_winnr, vim.cmd.diffthis)
end)
