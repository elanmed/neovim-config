local h = require "shared.helpers"
local bqf = require "bqf"

bqf.setup({
  auto_resize_height = true,
  func_map = {
    openc = "<cr>",
  },
  preview = {
    winblend = 0
  }
})

-- delete all quickfix lists
-- TODO: figure out a way to clear only one list, not all
h.nmap("gc", h.user_cmd_cb("cex \"\""))
