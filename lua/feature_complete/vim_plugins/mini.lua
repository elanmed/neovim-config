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

h.utils.lazy_setup(function()
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
end)
