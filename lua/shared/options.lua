local h = require "shared.helpers"

-- h.set.colorcolumn = "120"
h.set.clipboard = "unnamedplus" -- os clipboard
h.set.number = true             -- line numbers
h.set.errorbells = false        -- disable error beep
h.set.mouse = "nvi"             -- send vim commands with mouse in vim, prevents conflicts with tmux
h.set.confirm = true            -- prompt to save before quitting
h.set.linebreak = true          -- won't break on word when wrapping
h.set.splitright = true         -- when splitting vertically, open new split to the right
h.set.splitbelow = true         -- when splitting horizontally, open new split below
h.set.relativenumber = true     -- useful for multiline j, k
h.set.termguicolors = true      -- needed for modern themes
h.set.scrolloff = 8
h.set.fileencoding = "utf-8"

-- ignore checkhealth error
h.let.loaded_perl_provider = 0

-- spell
h.set.spelllang = "en_us"
h.set.spell = false -- TODO: look into

-- disable vim backups
h.set.swapfile = false
h.set.backup = false
h.set.writebackup = false

-- tabs
h.set.expandtab = true -- use spaces in tabs
h.set.tabstop = 2      -- number of columns in a tab
h.set.softtabstop = 2  -- number of spaces to delete when deleting a tab
h.set.shiftwidth = 2   -- number of spaces to insert/delete when in insert mode

-- search
h.set.ignorecase = true
h.keys.map({ "n", }, "<leader>/t", h.keys.user_cmd_cb "noh", { desc = "Turn off highlighting", })

-- folding
h.set.foldmethod = "expr"
h.set.foldcolumn = "0"                                        -- disable fold symbols in left column
h.set.foldlevelstart = 99                                     -- open folds by default
h.keys.map({ "n", }, "<leader>u", "za", { desc = "Toggle fold", }) -- toggle fold

h.set.foldexpr = "v:lua.GetFold(v:lnum)"

local function indent_level(lnum)
  return vim.fn.indent(lnum) / vim.o.shiftwidth + 1
end

function _G.GetFold(lnum)
  -- Check for blank lines
  if vim.fn.match(vim.fn.getline(lnum), [[\v^\s*$]]) ~= -1 then
    if indent_level(lnum - 1) == 1 then
      return 0
    end
    -- the foldlevel of this line is equal to the foldlevel of the line above or below it, whichever is smaller
    return "-1"
  end
  return indent_level(lnum)
end
