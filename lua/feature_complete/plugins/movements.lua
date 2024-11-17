local h = require "shared.helpers"

vim.api.nvim_set_var("VM_maps", { ["Add Cursor Down"] = "<C-t>" })

vim.api.nvim_create_autocmd({ "User" }, {
  pattern = "EasyMotionPromptBegin",
  callback = function() vim.b.coc_diagnostic_disable = 1 end
})
vim.api.nvim_create_autocmd({ "User" }, {
  pattern = "EasyMotionPromptEnd",
  callback = function() vim.b.coc_diagnostic_disable = 0 end
})

local leap = require "leap"
leap.create_default_mappings()
leap.opts.highlight_unlabeled_phase_one_targets = true

local harpoon = require "harpoon"
harpoon:setup({
  settings = {
    save_on_toggle = true,
  },
})

h.nmap("<C-b>", function() harpoon.ui:toggle_quick_menu(harpoon:list(), { ui_max_width = 80 }) end,
  { desc = "Toggle the harpoon window" })
h.nmap("<leader>r", function() harpoon:list():add() end, { desc = "Add a haRpoon entry" })

-- vim.api.nvim_set_hl(0, "FloatBorder", { fg = colors.orange, bg = colors.black })

require("flit").setup({})
require("marks").setup({
  excluded_filetypes = { "oil" },
  default_mappings = false,
  mappings = {
    toggle = "mt",
    next = "me",         -- nExt
    prev = "mr",         -- pRev
    delete_line = "dml", -- delete mark on the current Line
    delete_buf = "dma",  -- delete All
  }
})
