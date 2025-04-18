local h = require "shared.helpers"
local snacks = require "snacks"

--- @type snacks.Config
snacks.setup {
  indent = { enabled = true, animate = { enabled = false, }, },
  explorer = { enabled = true, replace_netrw = false, },
  scroll = { enabled = true, },
  picker = {
    win = {
      input = {
        keys = {
          ["<Esc>"] = { "close", mode = "i", },
          ["<C-c>"] = { "cancel", mode = "i", },
        },
      },
      list = {
        keys = {
          ["<C-u>"] = { "preview_scroll_up", mode = { "i", "n", }, },
          ["<C-d>"] = { "preview_scroll_down", mode = { "i", "n", }, },
        },
      },
    },
  },
}
