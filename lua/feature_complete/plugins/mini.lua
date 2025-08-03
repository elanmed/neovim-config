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
    hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack", },
    todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo", },
    note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote", },
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
}

local map = require "mini.map"
map.setup {
  integrations = {
    map.gen_integration.builtin_search(),
    map.gen_integration.diff(),
    map.gen_integration.diagnostic(),
  },
  symbols = {
    encode = map.gen_encode_symbols.dot "3x2",
  },
}

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    map.open()
  end,
})
