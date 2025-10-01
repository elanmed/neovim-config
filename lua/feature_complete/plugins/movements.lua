local flash = require "flash"

flash.setup {
  modes = {
    char = {
      enabled = false,
    },
  },
  prompt = {
    prefix = { { "󱐋 ", "FlashPromptIcon", }, },
  },
}

vim.keymap.set("n", "<leader>v", function() flash.treesitter() end)
vim.keymap.set("n", "<leader>s", function() flash.jump() end)
vim.keymap.set("n", "<leader>S", function()
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

require "marks".setup {
  excluded_filetypes = { "oil", },
  default_mappings = false,
  mappings = {
    toggle = "<leader>mt",
    next = "]a",
    prev = "[a",
    delete_buf = "<leader>md",
  },
}
