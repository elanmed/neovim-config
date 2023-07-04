local lualine = require "lualine"

-- TODO:
-- change in mode shouldn't update color
-- update color of text
-- update height?

lualine.setup({
  options = {
    disabled_filetypes = {
      "NvimTree"
    },
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    max_height = 4
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
        use_mode_colors = true,
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
