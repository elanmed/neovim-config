package.path = package.path .. ";../?.lua"
local h = require("elan.helpers")

h.nmap("H", ":BufferPrevious<cr>")
h.nmap("L", ":BufferNext<cr>")
h.nmap("<leader>tw", ":BufferClose<cr>")
h.nmap("<leader>to", ":BufferCloseAllButCurrent<cr>")
h.nmap("<leader>ta", ":BufferCloseAllButPinned<cr>")
h.nmap("<leader>ti", ":BufferPick<cr>")
