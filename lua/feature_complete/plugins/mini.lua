require "mini.surround".setup()
require "mini.indentscope".setup()
require "mini.icons".setup()
require "mini.cursorword".setup()
-- require "mini.tabline".setup()
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
    goto_next = "<C-l>",
    goto_prev = "<C-h>",
    goto_last = "",
  },
}

vim.keymap.set("n", "<C-b>", mini_diff.toggle_overlay, { desc = "Toggle mini diff overlay", })

local input_wasted_keys = function(key)
  local action = function()
    if vim.api.nvim_get_option_value("buftype", { buf = 0, }) == "quickfix" then return end
    if vim.api.nvim_get_option_value("filetype", { buf = 0, }) == "help" then return end
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
