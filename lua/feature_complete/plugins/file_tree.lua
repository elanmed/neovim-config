local mini_files = require "mini.files"
mini_files.setup {
  mappings = {
    close = "<esc>",
    go_in = "l",
    go_in_plus = "<cr>",
    go_out = "h",
    go_out_plus = "",
    mark_goto = "",
    mark_set = "",
    reset = "q",
    reveal_cwd = "",
    synchronize = "<bs>",
  },
  options = {
    permanent_delete = false,
    use_as_default_explorer = false,
  },
}

vim.keymap.set("n", "<leader>t", function()
  if not mini_files.close() then
    mini_files.open(vim.api.nvim_buf_get_name(0))
  end
end, { desc = "Toggle mini files", })

vim.keymap.set("n", "<C-f>", function()
  require "tree".tree {
    tree_win_opts = {
      signcolumn = "yes",
      relativenumber = true,
    },
  }
end)

vim.api.nvim_create_autocmd("FileType", {
  pattern = "tree",
  callback = function(args)
    vim.b.minicursorword_disable = true
    vim.keymap.set("n", "<cr>", "<Plug>TreeSelect", { buffer = args.buf, })
    vim.keymap.set("n", "q", "<Plug>TreeCloseTree", { buffer = args.buf, })
    vim.keymap.set("n", "<esc>", "<Plug>TreeCloseTree", { buffer = args.buf, })
    vim.keymap.set("n", "<C-f>", "<Plug>TreeCloseTree", { buffer = args.buf, })
    vim.keymap.set("n", "<", "<Plug>TreeDecreaseLevel", { buffer = args.buf, })
    vim.keymap.set("n", ">", "<Plug>TreeIncreaseLevel", { buffer = args.buf, })
    vim.keymap.set("n", "h", "<Plug>TreeOutDir", { buffer = args.buf, })
    vim.keymap.set("n", "l", "<Plug>TreeInDir", { buffer = args.buf, })
    vim.keymap.set("n", "yr", "<Plug>TreeYankRelativePath", { buffer = args.buf, })
    vim.keymap.set("n", "ya", "<Plug>TreeYankAbsolutePath", { buffer = args.buf, })
    vim.keymap.set("n", "o", "<Plug>TreeCreate", { buffer = args.buf, })
    vim.keymap.set("n", "e", "<Plug>TreeRefresh", { buffer = args.buf, })
    vim.keymap.set("n", "dd", "<Plug>TreeDelete", { buffer = args.buf, })
    vim.keymap.set("n", "r", "<Plug>TreeRename", { buffer = args.buf, })
  end,
})
