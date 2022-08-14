package.path = package.path .. ";../?.lua"
local h = require("elan.helpers")

h.nmap("<leader>tp", ":BufferPrevious<cr>")
h.nmap("<leader>tn", ":BufferNext<cr>")
h.nmap("<leader>tw", ":BufferClose<cr>")
h.nmap("<leader>to", ":BufferCloseAllButCurrent<cr>")
h.nmap("<leader>ti", ":BufferPick<cr>")
