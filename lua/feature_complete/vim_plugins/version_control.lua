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

vim.api.nvim_create_autocmd({ "FileType" }, {
  group = vim.api.nvim_create_augroup("GitDiffsMultiFileDiffViewRemaps", { clear = true }),
  pattern = "git-diffs-multi-file-diff-view-file-list",
  callback = function()
    vim.keymap.set("n", "<c-d>", "<Plug>GitDiffsMultiFileDiffViewScrollDown", { buffer = true })
    vim.keymap.set("n", "<c-u>", "<Plug>GitDiffsMultiFileDiffViewScrollUp", { buffer = true })
    vim.keymap.set("n", "<leader>e", "<Plug>GitDiffsMultiFileDiffViewRefresh", { buffer = true })
    vim.keymap.set("n", "o", "<Plug>GitDiffsMultiFileDiffViewSwitchToBuffer", { buffer = true })
  end,
})

vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("GitDiffsMultiFileDiffViewOpts", { clear = true }),
  pattern = "GitDiffsMultiFileDiffViewOpen",
  callback = function(ev)
    local old_winnr = ev.data.old_winnr
    local new_winnr = ev.data.new_winnr
    local file_list_winnr = ev.data.file_list_winnr

    vim.wo[old_winnr].statusline = " "
    vim.wo[new_winnr].statusline = " "
    vim.wo[file_list_winnr].statusline = " "
  end,
})
