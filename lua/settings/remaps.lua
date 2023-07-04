local h = require "shared/helpers"

h.nmap("<leader>gd", "<cmd>NvimTreeClose<cr>:DiffviewOpen<cr>")
h.nmap("<leader>gq", "<cmd>DiffviewClose<cr>")
h.nmap("L", "<cmd>bnext<cr>")
h.nmap("H", "<cmd>bprev<cr>")
h.nmap("<leader>tw", "<cmd>Bdelete<cr>")
h.nmap("<leader>ta", ":bufdo :Bdelete<cr>")

-- vim visual multi
-- vim.cmd([[
--    let g:VM_maps = {}
--    let g:VM_maps["Add Cursor Down"] = '<C-t>'
--  ]])
