local h = require "shared.helpers"
h.let.skip_ts_context_commentstring_module = true

require('ts_context_commentstring').setup({
  enable_autocmd = false
})
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
require("Comment.ft").lua = { "-- %s", "-- %s" }
