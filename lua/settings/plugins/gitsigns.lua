package.path = package.path .. ";../?.lua"
local h = require("settings.helpers")

local ok, gitsigns = pcall(require, "gitsigns")
if not ok then
  return
end

gitsigns.setup({
  current_line_blame_opts = {
    virt_text_pos = "right_align",
  },
})
h.nmap("<leader>gl", ":Gitsigns toggle_current_line_blame<CR>")
