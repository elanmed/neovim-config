package.path = package.path .. ";../?.lua"
local h = require("settings.helpers")

h.nmap("H", "<cmd>BufferPrevious<cr>")
h.nmap("L", "<cmd>BufferNext<cr>")
h.nmap("<leader>tw", "<cmd>BufferClose<cr>")
h.nmap("<leader>to", "<cmd>BufferCloseAllButCurrent<cr>")
h.nmap("<leader>ta", "<cmd>BufferCloseAllButPinned<cr>") -- aka close all
h.nmap("<leader>ti", "<cmd>BufferPick<cr>")
