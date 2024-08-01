local colors = require "settings.plugins.base16"

-- https://github.com/gelguy/wilder.nvim?tab=readme-ov-file#basic-config-for-both-vim-and-neovim
local wilder = require('wilder')
wilder.setup({ modes = { ':', '/', '?' } })

wilder.set_option('pipeline', {
  wilder.branch(
    wilder.cmdline_pipeline(),
    wilder.search_pipeline()
  ),
})

wilder.set_option('renderer', wilder.wildmenu_renderer({
  highlighter = wilder.basic_highlighter(),
}))

-- vim.api.nvim_set_hl(0, "WildMenu", { link = "CurSearch" })
vim.api.nvim_set_hl(0, "WildMenu", { link = "TermCursor" })
