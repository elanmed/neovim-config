package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/nvim/?.lua"
local h = require("shared.helpers")

vim.cmd("colorscheme tokyonight-day")
h.set.signcolumn = "yes" -- needed for linting symbols
h.set.showmode = false -- disrupts lualine
h.set.lazyredraw = true -- maybe helps performance?

vim.api.nvim_set_hl(0, 'CocFloating', { link = "Normal" })
