require "mini.surround".setup()
require "mini.indentscope".setup()
require "mini.icons".setup()
require "mini.move".setup()
require "mini.cursorword".setup()
require "mini.tabline".setup()
require "mini.splitjoin".setup()
require "mini.operators".setup {
  evaluate = { prefix = "", },
  sort = { prefix = "", },
}

local hipatterns = require "mini.hipatterns"
-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-hipatterns.md#example-usage
hipatterns.setup {
  highlighters = {
    fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme", },
    todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo", },
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
}
