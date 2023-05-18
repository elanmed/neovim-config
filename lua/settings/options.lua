local h = require "shared.helpers"

vim.cmd("colorscheme vscode")
h.set.signcolumn = "yes" -- needed for linting symbols
h.set.showmode = false   -- disrupts lualine
h.set.lazyredraw = true  -- maybe helps performance?

vim.api.nvim_set_hl(0, "CocFloating", { link = "Normal" })

vim.cmd([[
  autocmd User EasyMotionPromptBegin :let b:coc_diagnostic_disable = 1
  autocmd User EasyMotionPromptEnd :let b:coc_diagnostic_disable = 0
]])
