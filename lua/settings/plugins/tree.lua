package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/nvim/?.lua"
local h = require("shared.helpers")

local ok, tree = pcall(require, "nvim-tree")
if not ok then
  return
end

local function on_attach(bufnr)
  local api = require('nvim-tree.api')
  local opts = { buffer = bufnr, noremap = true, silent = true, nowait = true }

  -- TODO: update remap helpers to vim.keymap, update these
  vim.keymap.set('n', 'Y', api.fs.copy.absolute_path, opts)
  vim.keymap.set('n', 'H', api.tree.toggle_hidden_filter, opts)
  vim.keymap.set('n', '<CR>', api.node.open.edit, opts)
  vim.keymap.set('n', 'a', api.fs.create, opts)
  vim.keymap.set('n', 'd', api.fs.trash, opts)
end

tree.setup({
  on_attach = on_attach,
  hijack_cursor = true,
  view = {
    width = 40,
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

h.nmap("<leader>rb", "<cmd>NvimTreeToggle<cr>")
h.nmap("<leader>re", "<cmd>NvimTreeFindFileToggle<cr>")
