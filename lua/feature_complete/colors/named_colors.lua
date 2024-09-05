local colors = require "feature_complete.colors.all_colors"

local M = {
  black = colors.base00,
  grey = colors.base02,
  white = colors.base07,
  red = colors.base08,
  orange = colors.base09,
  yellow = colors.base0A,
  green = colors.base0B,
  cyan = colors.base0C,
  blue = colors.base0D,
  purple = colors.base0E,
  brown = colors.base0F,
}

vim.api.nvim_set_hl(0, "MatchParen", { fg = nil, bg = colors.base02 })

return M
