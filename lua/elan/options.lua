package.path = package.path .. ";../?.lua"
local h = require("elan.helpers")

vim.cmd("colorscheme vscode")

h.set.clipboard = "unnamedplus" -- os clipboard
h.set.number = true -- line numbers
h.set.errorbells = false -- disable error beep
h.set.mouse = "a" -- allow mouse to click, scroll
h.set.confirm = true -- prompt to save before quitting
h.set.linebreak = true -- won't break on word when wrapping
h.set.termguicolors = true -- needed for modern themes
h.set.fileencoding = "utf-8"
h.set.signcolumn = "yes" -- needed for linting symbols
h.set.showmode = false -- disrupts lualine
h.set.lazyredraw = true -- maybe helps performance?
h.set.splitright = true -- when splitting vertically, open new split to the right

-- backups
h.set.swapfile = false
h.set.backup = false
h.set.writebackup = false

-- tabs
h.set.expandtab = true -- use spaces in tabs
h.set.tabstop = 2 -- number of columns in a tab
h.set.softtabstop = 2 -- number of spaces to delete when deleting a tab
h.set.shiftwidth = 2 -- number of spaces to insert/delete when in insert mode

-- folding
h.set.foldmethod = "indent"
h.set.foldcolumn = "0" -- disable fold symbols in left column
h.set.foldlevelstart = 99 -- open folds by default
h.nmap("<leader>u", "za") -- toggle fold

-- search
h.set.ignorecase = true
h.nmap("<leader>/t", ":noh<cr>") -- turn off highlighting

-- search case sensitive, whole word, and both
vim.cmd([[
  noremap <leader>/c /\C<left><left>
  noremap <leader>/w /\<\><left><left>
  noremap <leader>cw /\<\>\C<left><left><left><left>
]])
