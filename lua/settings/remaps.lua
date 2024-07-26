local h = require "shared.helpers"
-- vim visual multi
vim.api.nvim_set_var("VM_maps", { ["Add Cursor Down"] = "<C-t>" })

-- TODO: come up with a better remap
-- h.nmap("'", function()
--   vim.cmd("q")
--   vim.cmd("q")
-- end)

h.nmap(":", function() print("use ; instead!") end)
