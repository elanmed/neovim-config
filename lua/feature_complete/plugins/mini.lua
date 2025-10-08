require "mini.surround".setup()
require "mini.indentscope".setup()
require "mini.icons".setup()
require "mini.cursorword".setup()
require "mini.tabline".setup()
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
