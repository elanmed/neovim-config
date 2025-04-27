local wilder = require "wilder"

-- disable wildchar
vim.keymap.set("c", "<tab>", "<nop>")
vim.keymap.set("c", "<s-tab>", "<nop>")

-- https://github.com/gelguy/wilder.nvim?tab=readme-ov-file#neovim-lua-only-config
wilder.setup { modes = { ":", }, next_key = "<C-n>", previous_key = "<C-p>", }

wilder.set_option("pipeline", {
  wilder.branch(
    wilder.cmdline_pipeline { fuzzy = 1, },
    wilder.vim_search_pipeline()
  ),
})
wilder.set_option("renderer", wilder.wildmenu_renderer
  {
    highlighter = wilder.lua_fzy_highlighter(),
    highlights = {
      accent = "WilderAccent",
      selected = "WildMenu",
    },
    left = { " ", wilder.wildmenu_spinner(), " ", },
    right = { " ", wilder.wildmenu_index(), },
  }
)
