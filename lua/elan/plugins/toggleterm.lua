package.path = package.path .. ";../?.lua"
local h = require("elan.helpers")

require("toggleterm").setup({})
h.map("", "<C-g>", ":ToggleTerm direction=float<CR>", {})
vim.cmd([[
  autocmd TermEnter term://*toggleterm#* tnoremap <silent><C-g> <Cmd>exe v:count1 . "ToggleTerm"<CR>
]])
