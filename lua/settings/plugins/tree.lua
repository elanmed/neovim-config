local h = require "shared.helpers"
local tree = require "nvim-tree"
local tree_view = require 'nvim-tree.view'

local function on_attach(bufnr)
  local api = require "nvim-tree.api"
  local opts = { buffer = bufnr }

  h.nmap("<CR>", api.node.open.edit, opts)
  h.nmap("a", api.fs.create, opts)
  h.nmap("d", api.fs.remove, opts)
  h.nmap("r", api.fs.rename, opts)
  h.nmap("t", api.marks.toggle, opts)
  h.nmap("m", api.marks.bulk.move, opts)
  h.nmap("y", api.fs.copy.relative_path, opts)
  h.nmap("c", api.fs.copy.node, opts)
  h.nmap("x", api.fs.cut, opts)
  h.nmap("p", api.fs.paste, opts)
  h.nmap("K", api.node.navigate.parent_close, opts)
  h.nmap("H", api.tree.toggle_hidden_filter, opts)
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

h.nmap("<leader>r", function()
  if tree_view.is_visible() then
    vim.cmd("NvimTreeClose")
  else
    vim.cmd("NvimTreeFindFile")
    vim.cmd("normal! zz")
  end
end)
