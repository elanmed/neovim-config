package.path = package.path .. ";../?.lua"
local h = require("settings.helpers")

local ok, toggleterm = pcall(require, "toggleterm")
if not ok then
  return
end

toggleterm.setup({})
h.map("", "<C-g>", "<cmd>ToggleTerm direction=horizontal<cr>")
vim.cmd([[
  autocmd TermEnter term://*toggleterm#* tnoremap <silent><C-g> <Cmd>exe v:count1 . "ToggleTerm"<cr>
]])
