local h = require "shared.helpers"
-- vim visual multi
vim.api.nvim_set_var("VM_maps", { ["Add Cursor Down"] = "<C-t>" })

h.nmap("<C-y>", function() vim.cmd("tabclose") end, { desc = "Close the current tab" })
