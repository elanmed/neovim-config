vim.keymap.set("n", "]c", "<Plug>GitHunksNextHunk")
vim.keymap.set("n", "[c", "<Plug>GitHunksPrevHunk")
vim.keymap.set("n", "gh", "<Plug>GitHunksResetHunk")
vim.keymap.set("v", "gh", "<Plug>GitHunksResetHunk")
vim.keymap.set("n", "gH", "<Plug>GitHunksResetFile")
vim.keymap.set("n", "<leader>d", function()
  require("git-diffs").toggle_multi_file_diff_view { diff_type = "worktree-index" }
end)
vim.keymap.set("n", "<leader>D", function()
  require("git-diffs").toggle_multi_file_diff_view { diff_type = "head-mergebase" }
end)
vim.keymap.set("n", "<C-b>", function()
  require("git-diffs").toggle_single_file_diff_view { diff_type = "worktree-index" }
end)

vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("GitDiffsMultiOpts", { clear = true }),
  pattern = "GitDiffsMultiBuffer",
  callback = function(ev)
    local data = ev.data
    vim.wo[data.old_winnr].statusline = " "
    vim.wo[data.new_winnr].statusline = " "
    vim.wo[data.file_list_winnr].statusline = " "

    for _, bufnr in ipairs { data.old_bufnr, data.new_bufnr, data.file_list_bufnr } do
      vim.keymap.set("n", "<C-n>", "<Plug>GitDiffsMultiListDown", { buffer = bufnr })
      vim.keymap.set("n", "<C-p>", "<Plug>GitDiffsMultiListUp", { buffer = bufnr })
      vim.keymap.set("n", "<leader>o", "<Plug>GitDiffsMultiSwitchBuffer", { buffer = bufnr })
      vim.keymap.set("n", "<leader>e", "<Plug>GitDiffsMultiRefresh", { buffer = bufnr })
    end

    vim.keymap.set("n", "<c-d>", "<Plug>GitDiffsMultiScrollDown", { buffer = data.file_list_bufnr })
    vim.keymap.set("n", "<c-u>", "<Plug>GitDiffsMultiScrollUp", { buffer = data.file_list_bufnr })
  end,
})
