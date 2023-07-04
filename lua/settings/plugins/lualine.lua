vim.cmd("colorscheme base16-tomorrow-night")
local lualine = require "lualine"

lualine.setup({
  options = {
    disabled_filetypes = {
      "NvimTree"
    },
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    theme = "base16",
    globalstatus = true
  },
  tabline = {
    lualine_a = {
      {
        "buffers",
        max_length = vim.o.columns,
        filetype_names = {
          TelescopePrompt = '',
          packer = '',
          fzf = '',
        },
      }
    },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
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
