local h = require "shared/helpers"
local diffview = require "diffview"

diffview.setup({
  file_panel = {
    win_config = {
      position = "bottom",
      height = 10,
    },
  },
})

h.nmap("<leader>gd", "<cmd>NvimTreeClose<cr>:DiffviewOpen<cr>")
h.nmap("<leader>gq", "<cmd>DiffviewClose<cr>")
