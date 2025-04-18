local h              = require "shared.helpers"

-- vim.o.colorcolumn    = "120"
vim.o.clipboard      = "unnamedplus" -- os clipboard
vim.o.cursorline     = true
vim.o.number         = true
vim.o.relativenumber = true
vim.o.errorbells     = false
-- prevents conflicts with tmux
vim.o.mouse          = "a"
vim.o.confirm        = true
vim.o.linebreak      = true
vim.o.splitright     = true
vim.o.splitbelow     = true
vim.o.termguicolors  = true -- needed for modern themes
vim.o.scrolloff      = 999
vim.o.conceallevel   = 0    -- keep quotes keys in normal mode
vim.o.undofile       = true
vim.o.ignorecase     = true
vim.cmd "set wildchar=<C-n>" -- TODO: issues setting in lua

vim.o.spelllang      = "en_us"
vim.o.spell          = false -- TODO: look into

-- disable vim backups
vim.o.swapfile       = false
vim.o.backup         = false
vim.o.writebackup    = false

vim.o.expandtab      = true -- use spaces in tabs
vim.o.tabstop        = 2    -- number of columns in a tab
vim.o.softtabstop    = 2    -- number of spaces to delete when deleting a tab
vim.o.shiftwidth     = 2    -- number of spaces to insert/delete when in insert mode

vim.o.foldmethod     = "expr"
vim.o.foldcolumn     = "0"
vim.o.foldlevelstart = 99
vim.o.foldmethod     = "expr"
vim.o.foldexpr       = "v:lua.vim.treesitter.foldexpr()"
