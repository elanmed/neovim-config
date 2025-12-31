vim.keymap.set("n", "<C-f>", function()
  require "tree".tree {
    tree_win_config = {
      border = "single",
    },
    tree_win_opts = {
      relativenumber = true,
      signcolumn = "no",
    },
  }
end, { desc = "Toggle tree", })

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("TreeRemaps", { clear = true, }),
  pattern = "tree",
  callback = function(args)
    vim.keymap.set("n", "<cr>", "<Plug>TreeSelect", { buffer = args.buf, })
    vim.keymap.set("n", "<C-f>", "<Plug>TreeCloseTree", { buffer = args.buf, })
    vim.keymap.set("n", "h", "<Plug>TreeOutDir", { buffer = args.buf, })
    vim.keymap.set("n", "l", "<Plug>TreeInDir", { buffer = args.buf, })
    vim.keymap.set("n", "yr", "<Plug>TreeYankRelativePath", { buffer = args.buf, })
    vim.keymap.set("n", "ya", "<Plug>TreeYankAbsolutePath", { buffer = args.buf, })
    vim.keymap.set("n", "yd", "<Plug>TreeYankDirectory", { buffer = args.buf, })
    vim.keymap.set("n", "yb", "<Plug>TreeYankBasename", { buffer = args.buf, })
    vim.keymap.set("n", "o", "<Plug>TreeCreate", { buffer = args.buf, })
    vim.keymap.set("n", "e", "<Plug>TreeRefresh", { buffer = args.buf, })
    vim.keymap.set("n", "r", "<Plug>TreeRename", { buffer = args.buf, })
    vim.keymap.set("n", "dd", "<Plug>TreeDelete", { buffer = args.buf, })
    vim.keymap.set("n", "yy", "<Plug>TreeCopy", { buffer = args.buf, })
    vim.keymap.set("n", "m", "<Plug>TreeMove", { buffer = args.buf, })

    vim.keymap.set("v", "d", "<Plug>TreeDelete", { buffer = args.buf, })
    vim.keymap.set("v", "yy", "<Plug>TreeCopy", { buffer = args.buf, })
    vim.keymap.set("v", "m", "<Plug>TreeMove", { buffer = args.buf, })
  end,
})
