package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/nvim/?.lua"
local h = require("shared.helpers")

local ok, gitsigns = pcall(require, "gitsigns")
if not ok then
  return
end

gitsigns.setup({
  current_line_blame_opts = {
    virt_text_pos = "right_align",
  },
})
h.nmap("<leader>gl", "<cmd>Gitsigns toggle_current_line_blame<cr>")
