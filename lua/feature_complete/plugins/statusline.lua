local h = require "shared.helpers"

h.set.showmode = false -- disrupts lualine
require("lualine").setup({
  options = {
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    globalstatus = true
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "filename" },
    lualine_c = {},
    lualine_x = {},
    lualine_y = { "branch" },
    lualine_z = { "filetype" },
  },
})
