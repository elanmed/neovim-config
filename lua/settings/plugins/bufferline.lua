local h = require "shared/helpers"

local bufferline = require "bufferline"
bufferline.setup({
  options = {
    diagnostics = "coc",
  }
})

h.nmap("<leader>tp", "<cmd>BufferLinePick<CR>")
h.nmap("<leader>ti", "<cmd>BufferLineTogglePin<CR>")
h.nmap("<leader>mn", "<cmd>BufferLineMoveNext<CR>")
h.nmap("<leader>mp", "<cmd>BufferLineMovePrev<CR>")
h.nmap("L", "<cmd>BufferLineCycleNext<CR>")
h.nmap("H", "<cmd>BufferLineCyclePrev<CR>")
