local h = require "helpers"

h.utils.lazy_setup(function() require "mini.icons".setup() end)
h.utils.lazy_setup(function() require "mini.splitjoin".setup() end)

h.utils.lazy_setup(function()
  local hipatterns = require "mini.hipatterns"
  -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-hipatterns.md#example-usage
  hipatterns.setup {
    highlighters = {
      todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo", },
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  }
end)

