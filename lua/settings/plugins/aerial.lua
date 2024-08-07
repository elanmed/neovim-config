local h = require "shared.helpers"

require("aerial").setup({
  lazy_load = false,
  show_guides = true,
  -- use automatic resizing
  layout = {
    max_width = nil,
    width = nil,
    min_width = nil,
  },
  keymaps = {
    ["<C-s>"] = "actions.close",
  }
})

h.nmap("<C-s>", h.user_cmd_cb("AerialOpen left"), { desc = "Toggle aerial  window" })
h.nmap("zn", h.user_cmd_cb("AerialNext"), { desc = "Go to the next aerial symbol" })
h.nmap("zp", h.user_cmd_cb("AerialPrev"), { desc = "Go to the prev aerial symbol" })

vim.api.nvim_set_hl(0, "AerialLine", { link = "Visual" })
