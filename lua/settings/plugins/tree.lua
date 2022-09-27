package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/nvim/?.lua"
local h = require("shared.helpers")

local ok, tree = pcall(require, "nvim-tree")
if not ok then
  return
end

tree.setup({
  hijack_cursor = true,
  view = {
    width = 60,
    mappings = {
      list = {
        { key = "Y", action = "copy_path" },
        { key = "<cr>", action = "tabnew" },
        { key = "s", action = "" },
      },
    },
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
h.nmap("<leader>re", "<cmd>NvimTreeFindFile<cr>")
