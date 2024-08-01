-- https://github.com/gelguy/wilder.nvim?tab=readme-ov-file#fuzzy-config-for-neovim-or-vim-with-yarp
local wilder = require('wilder')
wilder.setup({ modes = { ':', '/', '?' } })

wilder.set_option('pipeline', {
  wilder.branch(
    wilder.cmdline_pipeline({
      fuzzy = 1,
      set_pcre2_pattern = 1,
    }),
    wilder.python_search_pipeline({
      pattern = 'fuzzy',
    })
  ),
})

local highlighters = {
  wilder.pcre2_highlighter(),
  wilder.basic_highlighter(),
}

wilder.set_option('renderer', wilder.renderer_mux({
  [':'] = wilder.popupmenu_renderer({
    highlighter = highlighters,
  }),
  ['/'] = wilder.wildmenu_renderer({
    highlighter = highlighters,
  }),
}))

-- TODO: uncomment for horizontal autocomplete
-- vim.api.nvim_set_hl(0, "WildMenu", { link = "CurSearch" })
-- vim.api.nvim_set_hl(0, "WildMenu", { link = "TermCursor" })
