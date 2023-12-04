local comment = require "Comment"
local h = require "shared.helpers"

comment.setup {
  pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
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

local ft = require('Comment.ft')
ft.lua = { '-- %s', '-- %s' }

h.let.skip_ts_context_commentstring_module = true
