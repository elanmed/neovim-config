local h = require "shared/helpers"
local tree = require "nvim-tree"

local function on_attach(bufnr)
  local api = require "nvim-tree.api"
  local opts = { buffer = bufnr, noremap = true, silent = true, nowait = true }

  -- TODO: update remap helpers to vim.keymap, update these
  vim.keymap.set("n", "Y", api.fs.copy.absolute_path, opts)
  vim.keymap.set("n", "H", api.tree.toggle_hidden_filter, opts)
  vim.keymap.set("n", "<CR>", api.node.open.edit, opts)
  vim.keymap.set("n", "a", api.fs.create, opts)
  vim.keymap.set("n", "d", api.fs.trash, opts)
  vim.keymap.set("n", "r", api.fs.rename, opts)
end

tree.setup({
  on_attach = on_attach,
  hijack_cursor = true,
  view = {
    width = 60,
  },
  renderer = {
    highlight_opened_files = "all",
    highlight_git = true,
  },
  diagnostics = {
    enable = true,
    show_on_dirs = false,
  },
  git = {
    ignore = false,
  },
})

h.nmap("<leader>rw", "<cmd>NvimTreeToggle<cr>")
h.nmap("<leader>re", "<cmd>NvimTreeFindFileToggle<cr>")
