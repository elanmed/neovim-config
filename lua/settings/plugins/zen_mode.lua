local h = require "shared.helpers"
local zen_mode = require "zen-mode"

zen_mode.setup({
  window = {
    backdrop = 1,
    height = 0.5,
    options = {
      number = false,         -- disable number column
      relativenumber = false, -- disable relative numbers
    },
  },
  on_open = function()
    require("ibl").update({ enabled = false })
  end,
  on_close = function()
    require("ibl").update({ enabled = true })
  end,
})

h.nmap("<leader>zm", h.user_cmd_cb("ZenMode"))
