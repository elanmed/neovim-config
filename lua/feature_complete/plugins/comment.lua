local h = require "shared.helpers"
h.let.skip_ts_context_commentstring_module = true

return {
  "numToStr/Comment.nvim",
  commit = "e30b7f2",
  config = function()
    local ft = require "Comment.ft"
    ft.lua = { "-- %s", "-- %s" }
  end,
  dependencies = {
    {
      "JoosepAlviste/nvim-ts-context-commentstring",
      commit = "375c2d8",
      lazy = true,
      opts = {
        enable_autocmd = false,
      }
    }
  },
  config = function()
    require('Comment').setup({
      pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      toggler = {
        line = "<leader>cc",
        block = "<leader>bb",
      },
      -- multiple lines
      opleader = {
        line = "<leader>mc",
        block = "<leader>mb",
      },
      mappings = {
        basic = true,
        extra = false,
        extended = false,
      },
    })
  end
}
