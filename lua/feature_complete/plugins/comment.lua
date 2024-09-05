local h = require "shared.helpers"

local config = function()
  local ft = require "Comment.ft"
  ft.lua = { "-- %s", "-- %s" }

  h.let.skip_ts_context_commentstring_module = true
end

return {
  "numToStr/Comment.nvim",
  commit = "e30b7f2",
  config = config,
  opts = {
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
  }
}
