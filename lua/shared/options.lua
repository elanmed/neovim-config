local h              = require "shared.helpers"

-- h.set.colorcolumn = "120"
h.set.clipboard      = "unnamedplus" -- os clipboard
h.set.number         = true          -- line numbers
h.set.errorbells     = false         -- disable error beep
h.set.mouse          = "nvi"         -- send vim commands with mouse in vim, prevents conflicts with tmux
h.set.confirm        = true          -- prompt to save before quitting
h.set.linebreak      = true          -- won't break on word when wrapping
h.set.splitright     = true          -- when splitting vertically, open new split to the right
h.set.splitbelow     = true          -- when splitting horizontally, open new split below
h.set.relativenumber = true          -- useful for multiline j, k
h.set.termguicolors  = true          -- needed for modern themes
h.set.scrolloff      = 16
h.set.fileencoding   = "utf-8"
h.set.conceallevel   = 0     -- keep quotes keys in normal mode
h.set.undofile       = true  -- persist undo tree across sessions
vim.cmd "set wildchar=<C-n>" -- TODO: issues setting in lua

-- ignore checkhealth error
h.let.loaded_perl_provider = 0

-- spell
h.set.spelllang            = "en_us"
h.set.spell                = false -- TODO: look into

-- disable vim backups
h.set.swapfile             = false
h.set.backup               = false
h.set.writebackup          = false

-- tabs
h.set.expandtab            = true -- use spaces in tabs
h.set.tabstop              = 2    -- number of columns in a tab
h.set.softtabstop          = 2    -- number of spaces to delete when deleting a tab
h.set.shiftwidth           = 2    -- number of spaces to insert/delete when in insert mode

-- search
h.set.ignorecase           = true

-- folding
h.set.foldmethod           = "expr"
h.set.foldcolumn           = "0" -- disable fold symbols in left column
h.set.foldlevelstart       = 99  -- open folds by default

h.set.foldmethod           = "expr"
h.set.foldexpr             = "v:lua.vim.treesitter.foldexpr()"
