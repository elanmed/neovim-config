package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/nvim/?.lua"
local h = require("shared.helpers")

local ok, toggleterm = pcall(require, "toggleterm")
if not ok then
  return
end

toggleterm.setup({
  size = 20,
  shade_terminals = false
})
h.map("", "<C-g>", "<cmd>ToggleTerm direction=horizontal<cr>")
vim.cmd([[
  autocmd TermEnter term://*toggleterm#* tnoremap <silent><C-g> <Cmd>exe v:count1 . "ToggleTerm"<cr>
]])
