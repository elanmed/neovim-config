local snacks = require "snacks"
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

-- https://github.com/folke/snacks.nvim/blob/main/docs/rename.md#minifiles
vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesActionRename",
  callback = function(event)
    snacks.rename.on_rename_file(event.data.from, event.data.to)
  end,
})
local tree_keymaps = {
  ["<cr>"] = "select",
  ["q"] = "close-tree",
  ["<esc>"] = "close-tree",
  ["<C-f>"] = "close-tree",
  ["<"] = "dec-limit",
  [">"] = "inc-limit",
  ["h"] = "out-dir",
  ["l"] = "in-dir",
}

vim.keymap.set("n", "<C-f>", function()
  require "tree".tree {
    keymaps = tree_keymaps,
  }
end)

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if vim.fn.isdirectory(bufname) == require "helpers".vimscript_true then
      require "tree".tree { keymaps = tree_keymaps, }
    end
  end,
})
