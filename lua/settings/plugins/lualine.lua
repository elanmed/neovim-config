vim.cmd("colorscheme base16-tomorrow-night")
local lualine = require "lualine"

lualine.setup({
  options = {
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    theme = "base16",
    globalstatus = true
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "filename" },
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { "filetype" },
  },
})
