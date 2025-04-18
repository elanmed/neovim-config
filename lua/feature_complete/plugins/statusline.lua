local h = require "shared.helpers"

h.set.showmode = false -- disrupts lualine
require "lualine".setup {
  options = {
    component_separators = { left = "", right = "", },
    section_separators = { left = "", right = "", },
    globalstatus = true,
  },
  sections = {
    lualine_a = { "mode", },
    lualine_b = {
      {
        "filename",
        path = 3, -- absolute path, with tilde as the home directory
      },
    },
    lualine_x = { "progress", },
    lualine_y = { "branch", },
    lualine_z = { "lsp_status", "filetype", },
  },
}
