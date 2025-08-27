local h = require "helpers"
local mini_pairs = require "mini.pairs"
mini_pairs.setup()
local mini_cmp = require "mini.completion"

vim.keymap.set("i", "<C-n>", function()
  return vim.fn.pumvisible() == h.vimscript_true and "<C-n>" or nil
end, { expr = true, })

vim.keymap.set("i", "<CR>", function()
    -- :h MiniCompletion
    if vim.fn.complete_info()["selected"] ~= -1 then
      return "\25"
    end
    return mini_pairs.cr()
  end,
  { expr = true, }
)

mini_cmp.setup {
  -- delay = { completion = 10 ^ 7, },
  lsp_completion = {
    process_items = function(items, base)
      return mini_cmp.default_process_items(items, base, { filtersort = "fuzzy", kind_priority = { Snippet = -1, }, })
    end,
  },
  mappings = {
    force_twostep = "<C-x>",
    force_fallback = "",
  },
}

vim.opt.completeopt = "menuone,noselect,fuzzy"
