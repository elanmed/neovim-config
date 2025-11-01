require "mini.surround".setup {
  mappings = {
    add = "ys",
    delete = "ds",
    find = "",
    find_left = "",
    highlight = "",
    replace = "cs",
    suffix_last = "",
    suffix_next = "",
  },
  search_method = "cover_or_next",
}
require "mini.icons".setup()
require "mini.splitjoin".setup()

local hipatterns = require "mini.hipatterns"
-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-hipatterns.md#example-usage
hipatterns.setup {
  highlighters = {
    fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme", },
    todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo", },
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
}

local mini_diff = require "mini.diff"
mini_diff.setup {
  view = { style = "number", },
  mappings = {
    apply = "",
    reset = "gh",
    goto_first = "",
    goto_next = "]g",
    goto_prev = "[g",
    goto_last = "",
  },
}

vim.keymap.set("n", "<C-b>", mini_diff.toggle_overlay, { desc = "Toggle mini diff overlay", })

local input_wasted_keys = function(key)
  local action = function()
    if vim.bo.buftype ~= "" then return end
    vim.fn.input "Wasted keys: "
  end
  require "mini.keymap".map_combo("n", string.rep(key, 5), action)
end
input_wasted_keys "h"
input_wasted_keys "j"
input_wasted_keys "k"
input_wasted_keys "l"
input_wasted_keys "w"
input_wasted_keys "b"
