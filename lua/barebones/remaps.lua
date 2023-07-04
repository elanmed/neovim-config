local h = require "shared/helpers"

h.nmap("<leader>re", ":Lexplore<cr>")
h.nmap("L", "<cmd>bnext<cr>")
h.nmap("H", "<cmd>bprev<cr>")
h.nmap("<leader>tw", "<cmd>bd<cr>")
h.nmap("<leader>ta", ":bufdo :bd<cr>")
