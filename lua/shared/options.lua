local h              = require "shared.helpers"

-- h.set.colorcolumn    = "120"
h.set.clipboard      = "unnamedplus" -- os clipboard
h.set.cursorline     = true
h.set.number         = true
h.set.relativenumber = true
h.set.errorbells     = false
-- prevents conflicts with tmux
h.set.mouse          = "a"
h.set.confirm        = true
h.set.linebreak      = true
h.set.splitright     = true
h.set.splitbelow     = true
h.set.termguicolors  = true -- needed for modern themes
h.set.scrolloff      = 999
h.set.conceallevel   = 0    -- keep quotes keys in normal mode
h.set.undofile       = true
h.set.ignorecase     = true
vim.cmd "set wildchar=<C-n>" -- TODO: issues setting in lua

h.set.spelllang      = "en_us"
h.set.spell          = false -- TODO: look into

-- disable vim backups
h.set.swapfile       = false
h.set.backup         = false
h.set.writebackup    = false

h.set.expandtab      = true -- use spaces in tabs
h.set.tabstop        = 2    -- number of columns in a tab
h.set.softtabstop    = 2    -- number of spaces to delete when deleting a tab
h.set.shiftwidth     = 2    -- number of spaces to insert/delete when in insert mode

h.set.foldmethod     = "expr"
h.set.foldcolumn     = "0"
h.set.foldlevelstart = 99
h.set.foldmethod     = "expr"
h.set.foldexpr       = "v:lua.vim.treesitter.foldexpr()"
