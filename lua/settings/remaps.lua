local h = require "shared.helpers"
-- vim visual multi
vim.api.nvim_set_var("VM_maps", { ["Add Cursor Down"] = "<C-t>" })

h.nmap("<C-y>", function()
  vim.cmd("q")
  vim.cmd("q")
end, { desc = "The quit command twice, or how to navigate from one git diff to the next" })
