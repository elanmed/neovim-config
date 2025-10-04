local mini_cmp = require "mini.completion"
require "nvim-autopairs".setup {}

mini_cmp.setup {
  delay = { completion = 10 ^ 7, },
  lsp_completion = {
    process_items = function(items, base)
      return mini_cmp.default_process_items(items, base, { filtersort = "fuzzy", kind_priority = { Snippet = -1, }, })
    end,
  },
  mappings = {
    force_twostep = "<C-x><C-o>",
    force_fallback = "<C-x><C-n>",
  },
}
