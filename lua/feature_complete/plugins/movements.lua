local h = require "shared.helpers"

-- TODO: find a new remap
-- vim.api.nvim_set_var("VM_maps", { ["Add Cursor Down"] = "<C-t>", })

local leap = require "leap"
leap.create_default_mappings()
leap.opts.highlight_unlabeled_phase_one_targets = true

local harpoon = require "harpoon"
harpoon:setup {
  settings = {
    save_on_toggle = true,
  },
}

h.keys.map({ "n", }, "<C-g>",
  function()
    harpoon.ui:toggle_quick_menu(harpoon:list(), { ui_max_width = 80, })
  end,
  { desc = "Toggle the harpoon window", })
h.keys.map({ "n", }, "<leader>ad", function()
  harpoon:list():add()
end, { desc = "Add a haRpoon entry", })

require "marks".setup {
  excluded_filetypes = { "oil", },
  default_mappings = false,
  mappings = {
    toggle = "mt",
    next = "me",         -- nExt
    prev = "mr",         -- pRev
    delete_line = "dml", -- delete mark on the current Line
    delete_buf = "dma",  -- delete All
  },
}
