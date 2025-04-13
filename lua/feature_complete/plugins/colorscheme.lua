local h = require "shared.helpers"
local base16 = require "base16-colorscheme"

-- tomorrow-night
local colors = {
  base00 = "#1d1f21",
  base01 = "#282a2e",
  base02 = "#373b41",
  base03 = "#969896",
  base04 = "#b4b7b4",
  base05 = "#c5c8c6",
  base06 = "#e0e0e0",
  base07 = "#ffffff",
  base08 = "#cc6666",
  base09 = "#de935f",
  base0A = "#f0c674",
  base0B = "#b5bd68",
  base0C = "#8abeb7",
  base0D = "#81a2be",
  base0E = "#b294bb",
  base0F = "#a3685a",
}
base16.setup(colors)
local M = {
  black = colors.base00,
  grey = colors.base02,
  light_grey = colors.base03,
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

vim.api.nvim_set_hl(h.curr.namespace, "MatchParen", { fg = nil, bg = M.grey, })
vim.api.nvim_set_hl(h.curr.namespace, "LspReferenceRead", { bg = "#2e3136", })  -- between base01 and base 02
vim.api.nvim_set_hl(h.curr.namespace, "LspReferenceText", { bg = "#2e3136", })  -- between base01 and base 02
vim.api.nvim_set_hl(h.curr.namespace, "LspReferenceWrite", { bg = "#2e3136", }) -- between base01 and base 02

vim.api.nvim_set_hl(h.curr.namespace, "PmenuBorder", { fg = M.light_grey, })
vim.api.nvim_set_hl(h.curr.namespace, "TelescopeBorder", { link = "PmenuBorder", })
vim.api.nvim_set_hl(h.curr.namespace, "FloatBorder", { link = "PmenuBorder", }) -- harpoon border
vim.api.nvim_set_hl(h.curr.namespace, "CursorLine", { link = "Visual", })
vim.api.nvim_set_hl(h.curr.namespace, "AerialLine", { link = "Visual", })
vim.api.nvim_set_hl(h.curr.namespace, "WilderAccent", { fg = M.orange, })
vim.api.nvim_set_hl(h.curr.namespace, "WildMenu", { fg = M.yellow, underline = true, bold = true, })

vim.api.nvim_set_hl(h.curr.namespace, "FlashMatch", { link = "Search", })
vim.api.nvim_set_hl(h.curr.namespace, "FlashLabel", { link = "IncSearch", })
vim.api.nvim_set_hl(h.curr.namespace, "FlashCurrent", { bg = M.red, fg = colors.base01, })
vim.api.nvim_set_hl(h.curr.namespace, "FlashCurrent", { bg = M.red, fg = colors.base01, })

vim.api.nvim_set_hl(h.curr.namespace, "SnacksIndent", { fg = M.grey, })
vim.api.nvim_set_hl(h.curr.namespace, "SnacksIndentScope", { fg = M.light_grey, })

vim.api.nvim_set_hl(h.curr.namespace, "NotifyWarning", { fg = M.yellow, })
vim.api.nvim_set_hl(h.curr.namespace, "NotifyError", { fg = M.red, })
vim.api.nvim_set_hl(h.curr.namespace, "NotifyInfo", { fg = M.green, })
vim.api.nvim_set_hl(h.curr.namespace, "NotifyToggleOn", { fg = M.green, })
vim.api.nvim_set_hl(h.curr.namespace, "NotifyToggleOff", { fg = M.purple, })

vim.api.nvim_set_hl(h.curr.namespace, "FTPreviewSecond", { fg = M.yellow, underline = true, bold = true, })
vim.api.nvim_set_hl(h.curr.namespace, "FTPreviewThird", { fg = M.red, underline = true, bold = true, })
vim.api.nvim_set_hl(h.curr.namespace, "FTPreviewDimmed", { fg = M.light_grey, })

return M
