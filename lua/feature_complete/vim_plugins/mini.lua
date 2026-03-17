vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local icons = require "mini.icons"
    icons.setup()
    icons.tweak_lsp_kind()
    require "mini.splitjoin".setup()
  end,
})
