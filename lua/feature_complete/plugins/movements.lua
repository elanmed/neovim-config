local flash = require "flash"
flash.setup { prompt = { prefix = {}, }, }

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
