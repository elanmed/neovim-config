local h = require "shared.helpers"

-- vim visual multi
vim.api.nvim_set_var('VM_maps', { ["Add Cursor Down"] = '<C-t>' })

-- markdown preview
h.nmap("<leader>mp", h.user_cmd_cb("MarkdownPreviewToggle"))
