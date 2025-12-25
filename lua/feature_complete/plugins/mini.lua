local h = require "helpers"

h.utils.lazy_load(function() require "mini.icons".setup() end)
h.utils.lazy_load(function() require "mini.splitjoin".setup() end)

h.utils.lazy_load(function()
  local hipatterns = require "mini.hipatterns"
  -- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-hipatterns.md#example-usage
  hipatterns.setup {
    highlighters = {
      todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo", },
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  }
end)

h.utils.lazy_load(function()
  local mini_diff = require "mini.diff"
  mini_diff.setup {
    view = { style = "number", },
    mappings = {
      apply = "",
      reset = "gh",
      goto_first = "",
      goto_next = "]c",
      goto_prev = "[c",
      goto_last = "",
    },
  }
end)

h.utils.lazy_load(function()
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
