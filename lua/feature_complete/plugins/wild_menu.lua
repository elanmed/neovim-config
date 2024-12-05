local colors = require "feature_complete.plugins.colorscheme"
local wilder = require "wilder"

-- https://github.com/gelguy/wilder.nvim?tab=readme-ov-file#neovim-lua-only-config
wilder.setup { modes = { ":", }, next_key = "<C-n>", previous_key = "<C-p>", }
wilder.set_option("use_python_remote_plugin", 0)
wilder.set_option("pipeline", {
  wilder.branch(
    wilder.cmdline_pipeline {
      fuzzy = 1,
      fuzzy_filter = wilder.lua_fzy_filter(),
    },
    wilder.vim_search_pipeline()

  ),
})
wilder.set_option("renderer", wilder.popupmenu_renderer(
  wilder.popupmenu_border_theme {
    border = { "", "", "", "", "", "", "", "", },
    highlighter = wilder.lua_fzy_highlighter(),
    highlights = {
      accent = wilder.make_hl("WilderAccent", "Pmenu", { { a = 1, }, { a = 1, }, { foreground = colors.orange, }, }),
    },
    min_width = "50%",
    max_height = "20%",
    left = {
      " ",
      wilder.popupmenu_devicons(),
    },
    right = {
      " ",
      wilder.popupmenu_scrollbar(),
    },
  }
))
