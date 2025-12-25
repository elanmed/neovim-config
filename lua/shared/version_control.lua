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
  local head_lines = vim.split(stdout, "\n", { trimempty = true, })

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
