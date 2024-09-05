local h = require "shared.helpers"

return {
  "folke/zen-mode.nvim",
  commit = "29b292b",
  opts = {
    window = {
      backdrop = 1,
      height = 0.5,
      options = {
        number = false,
        relativenumber = false,
      },
    },
    on_open = function()
      require("ibl").update({ enabled = false })
    end,
    on_close = function()
      require("ibl").update({ enabled = true })
    end,
  },
  keys = {
    { "<leader>zm", h.user_cmd_cb("ZenMode"), desc = "Toggle zen mode" }
  }
}
