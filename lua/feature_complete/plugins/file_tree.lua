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
    keymaps = {
      ["<cr>"] = "select",
      ["<esc>"] = "close-tree",
      ["<C-f>"] = "close-tree",
      ["<"] = "dec-level",
      [">"] = "inc-level",
      q = "close-tree",
      h = "out-dir",
      l = "in-dir",
      yr = "yank-rel-path",
      ya = "yank-abs-path",
      o = "create",
      e = "refresh",
      dd = "delete",
      r = "rename",
    },
    tree_win_opts = {
      signcolumn = "yes",
      relativenumber = true,
    },
  }
end)
