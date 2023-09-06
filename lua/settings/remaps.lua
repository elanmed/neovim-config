local h = require "shared.helpers"

-- vim visual multi
vim.cmd([[
   let g:VM_maps = {}
   let g:VM_maps["Add Cursor Down"] = '<C-t>'
 ]])

-- markdown preview
h.nmap("<leader>mp", h.user_command_cb("MarkdownPreviewToggle"))
