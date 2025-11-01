vim.o.clipboard = "unnamedplus" -- os clipboard
vim.o.cursorline = true
vim.o.relativenumber = true
vim.o.number = true
vim.o.confirm = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.termguicolors = true -- needed for modern themes
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.signcolumn = "yes"
vim.o.linebreak = true
vim.o.breakindent = true -- wrapped lines will be properly indented
vim.o.spelllang = "en_us"
vim.o.spell = false -- TODO: look into
vim.o.expandtab = true -- use spaces in tabs
vim.o.tabstop = 2 -- number of columns in a tab
vim.o.softtabstop = 2 -- number of spaces to delete when deleting a tab
vim.o.shiftwidth = 2 -- number of spaces to insert/delete when in insert mode
-- disable vim backups
vim.o.swapfile = false
vim.o.backup = false
vim.o.writebackup = false
vim.o.laststatus = 0
vim.o.ruler = false
vim.o.showcmd = false
vim.opt.suffixesadd = {
  ".tsx", ".jsx", ".ts", ".js",
  "index.tsx", "index.jsx", "index.ts", "index.js",
}
vim.opt.completeopt = { "menuone", "noselect", "fuzzy", "popup", }
vim.o.pumborder = "single"
vim.o.wildmode = "noselect"
vim.o.wildoptions = "fuzzy"
vim.o.list = true
vim.o.listchars = "leadmultispace:│ ,trail:·,nbsp:◇"
