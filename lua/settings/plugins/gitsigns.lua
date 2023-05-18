local h = require "shared.helpers"

local gitsigns = require "gitsigns"

gitsigns.setup({
  current_line_blame_opts = {
    virt_text_pos = "right_align",
  },
})
h.nmap("<leader>gl", "<cmd>Gitsigns toggle_current_line_blame<cr>")
