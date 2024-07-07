local h = require "shared.helpers"
local zen_mode = require "zen-mode"

zen_mode.setup({
  window = {
    backdrop = 1,
    height = 0.5,
  },
  plugins = {
    gitsigns = { enabled = true },
    tmux = { enabled = true },
  },
})

h.nmap("<leader>zm", h.user_cmd_cb(":ZenMode"))
