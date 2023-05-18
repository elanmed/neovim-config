local h = require "shared.helpers"

h.nmap("<leader>gd", "<cmd>NvimTreeClose<cr>:DiffviewOpen<cr>")
h.nmap("<leader>gq", "<cmd>DiffviewClose<cr>")
h.nmap("<leader>mp", "<cmd>MarkdownPreview<cr>")

-- vim visual multi
-- vim.cmd([[
--   let g:VM_maps = {}
--   let g:VM_maps["Add Cursor Down"] = '<C-k>'
-- ]])
