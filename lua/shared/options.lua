-- vim.opt.colorcolumn    = "120"
vim.opt.clipboard      = "unnamedplus" -- os clipboard
vim.opt.cursorline     = true
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.errorbells     = false
-- prevents conflicts with tmux
vim.opt.mouse          = "a"
vim.opt.confirm        = true
vim.opt.linebreak      = true
vim.opt.splitright     = true
vim.opt.splitbelow     = true
vim.opt.termguicolors  = true -- needed for modern themes
vim.opt.scrolloff      = 999
vim.opt.conceallevel   = 0    -- keep quotes keys in normal mode
vim.opt.undofile       = true
vim.opt.ignorecase     = true
vim.opt.signcolumn     = "yes"

vim.opt.spelllang      = "en_us"
vim.opt.spell          = false -- TODO: look into

-- disable vim backups
vim.opt.swapfile       = false
vim.opt.backup         = false
vim.opt.writebackup    = false

vim.opt.expandtab      = true -- use spaces in tabs
vim.opt.tabstop        = 2    -- number of columns in a tab
vim.opt.softtabstop    = 2    -- number of spaces to delete when deleting a tab
vim.opt.shiftwidth     = 2    -- number of spaces to insert/delete when in insert mode

vim.opt.foldmethod     = "expr"
vim.opt.foldcolumn     = "0"
vim.opt.foldlevelstart = 99
vim.opt.foldmethod     = "expr"
vim.opt.foldexpr       = "v:lua.vim.treesitter.foldexpr()"
