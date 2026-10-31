vim.keymap.set("n", "]c", "<Plug>GitHunksNextHunk")
vim.keymap.set("n", "[c", "<Plug>GitHunksPrevHunk")
vim.keymap.set("n", "gh", "<Plug>GitHunksResetHunk")
vim.keymap.set("v", "gh", "<Plug>GitHunksResetHunk")
vim.keymap.set("n", "gH", "<Plug>GitHunksResetFile")
vim.keymap.set("n", "<leader>d", function()
  require("git-diffs").toggle_diff_view { diff_type = "worktree-index" }
end)
vim.keymap.set("n", "<leader>D", function()
  require("git-diffs").toggle_diff_view { diff_type = "head-mergebase" }
end)

vim.api.nvim_create_autocmd({ "FileType" }, {
  group = vim.api.nvim_create_augroup("GitDiffViewRemaps", { clear = true }),
  pattern = "git-diffs-view-file-list",
  callback = function()
    vim.keymap.set("n", "<c-d>", "<Plug>GitHunksViewScrollDown", { buffer = true })
    vim.keymap.set("n", "<c-u>", "<Plug>GitHunksViewScrollUp", { buffer = true })
    vim.keymap.set("n", "<leader>e", "<Plug>GitHunksViewRefresh", { buffer = true })
  end,
})

vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("GitDiffViewOpts", { clear = true }),
  pattern = "GitDiffViewOpen",
  callback = function(ev)
    local old_winnr = ev.data.old_winnr
    local new_winnr = ev.data.new_winnr
    local file_list_winnr = ev.data.file_list_winnr

    vim.wo[old_winnr].statusline = " "
    vim.wo[new_winnr].statusline = " "
    vim.wo[file_list_winnr].statusline = " "
  end,
})
