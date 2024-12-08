local h = require "shared.helpers"
local colors = require "feature_complete.plugins.colorscheme"
local wilder = require "wilder"

vim.api.nvim_set_hl(0, "WilderAccent", { fg = colors.orange, })

-- https://github.com/gelguy/wilder.nvim?tab=readme-ov-file#neovim-lua-only-config
wilder.setup { modes = { ":", }, next_key = "<C-n>", previous_key = "<C-p>", }
wilder.set_option("pipeline", {
  wilder.branch(
    wilder.cmdline_pipeline { fuzzy = 1, },
    wilder.vim_search_pipeline()
  ),
})
wilder.set_option("renderer", wilder.popupmenu_renderer(
  wilder.popupmenu_border_theme {
    highlighter = wilder.lua_fzy_highlighter(),
    highlights = {
      accent = "WilderAccent",
      selected = "Visual",
      border = "PmenuBorder",
    },
    min_width = "50%",
    max_height = "20%",
    left = { " ", wilder.popupmenu_devicons(), },
    right = { " ", wilder.popupmenu_scrollbar(), }, }
))
