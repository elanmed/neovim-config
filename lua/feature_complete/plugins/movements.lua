local h = require "shared.helpers"
local flash = require "flash"

flash.setup {
  modes = {
    char = {
      enabled = true,
      multi_line = false,
      keys = { "f", "F", "t", "T", },
      jump_labels = true,
    },
  },
  prompt = {
    prefix = { { "󱐋 ", "FlashPromptIcon", }, },
  },
}
h.keys.map("n", "s", function() flash.jump { forward = true, } end)
h.keys.map("n", "S", function() flash.jump { forward = false, } end)
h.keys.map("n", "<leader>sa", function()
  -- https://github.com/folke/flash.nvim#-examples
  flash.jump {
    forward = true,
    search = {
      mode = "search",
      max_length = 0,
    },
    label = {
      after = { 0, 0, },
    },
    pattern = "^",
  }
end)

local harpoon = require "harpoon"
harpoon:setup {
  settings = {
    save_on_toggle = true,
  },
}

h.keys.map("n", "<leader>at",
  function()
    harpoon.ui:toggle_quick_menu(harpoon:list(), { ui_max_width = 80, })
  end,
  { desc = "Toggle the harpoon window", })
h.keys.map("n", "<leader>ad", function()
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
