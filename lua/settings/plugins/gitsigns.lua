local h = require "shared.helpers"

local gitsigns = require "gitsigns"

gitsigns.setup({
  current_line_blame_opts = {
    virt_text_pos = "right_align",
  },
})
h.nmap("<leader>gl", h.user_cmd_cb("Gitsigns toggle_current_line_blame"))
