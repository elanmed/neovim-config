local h = require "shared.helpers"
local tree = require "nvim-tree"

local function on_attach(bufnr)
  local api = require "nvim-tree.api"
  local opts = { buffer = bufnr }

  h.nmap("Y", api.fs.copy.absolute_path, opts)
  h.nmap("H", api.tree.toggle_hidden_filter, opts)
  h.nmap("<CR>", api.node.open.edit, opts)
  h.nmap("a", api.fs.create, opts)
  h.nmap("d", api.fs.remove, opts)
  h.nmap("r", api.fs.rename, opts)
  h.nmap("t", api.marks.toggle, opts)
  h.nmap("m", api.marks.bulk.move, opts)
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

h.nmap("<leader>rw", h.user_cmd_cb("NvimTreeClose"))
h.nmap("<leader>re", function()
  vim.cmd("NvimTreeFindFile")
  vim.cmd("normal! zz")
end)
