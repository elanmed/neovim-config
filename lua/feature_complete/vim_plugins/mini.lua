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

local function setup_wasted_key_detection(key, threshold)
  local press_count = 0
  local timer = nil

  vim.keymap.set("n", key, function()
    if vim.bo.buftype ~= "" then
      press_count = 0
      return vim.api.nvim_feedkeys(vim.v.count .. key, "n", false)
    end

    press_count = press_count + 1
    if timer then vim.fn.timer_stop(timer) end

    if press_count >= threshold then
      press_count = 0
      vim.fn.input "Wasted keys: "
      return
    end

    timer = vim.fn.timer_start(200, function()
      press_count = 0
    end)

    vim.api.nvim_feedkeys(vim.v.count .. key, "n", false)
  end)
end

local wasted_keys = { "h", "j", "k", "l", "w", "b", }
for _, key in ipairs(wasted_keys) do
  setup_wasted_key_detection(key, 5)
end
