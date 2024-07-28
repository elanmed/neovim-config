local neoscroll = require "neoscroll"
local h = require "shared.helpers"
local colors = require "settings.plugins.base16"

local function is_override_filetype()
  return h.table_contains({ "oil" }, vim.bo.filetype)
end

neoscroll.setup({
  hide_cursor = false,
  pre_hook = function()
    if is_override_filetype() then return end

    h.set.cursorline = true
    vim.api.nvim_set_hl(0, "CursorLine", { link = "Visual" })
  end,
  post_hook = function()
    if is_override_filetype() then return end
    h.set.cursorline = false
  end
})

local function get_current_line()
  return vim.api.nvim_win_get_cursor(0)[1]
end

local function is_first_line()
  local current_line = get_current_line()
  return current_line == 1
end

local function is_last_line()
  local current_line = get_current_line()
  local last_line = vim.fn.line("$")
  return current_line == last_line
end

local modes = { "n", "v", "x" }
for _, mode in pairs(modes) do
  h.map(mode, "<C-u>", function()
    h.send_keys("0")
    if is_override_filetype() then
      neoscroll.ctrl_u({ duration = 250 })
      return
    end

    if is_last_line() then
      h.send_keys("M")
    else
      neoscroll.ctrl_u({ duration = 250 })
    end
  end)

  h.map(mode, "<C-d>", function()
    h.send_keys("0")
    if is_override_filetype() then
      neoscroll.ctrl_d({ duration = 250 })
      return
    end

    if is_first_line() then
      h.send_keys("M")
    else
      neoscroll.ctrl_d({ duration = 250 })
    end
  end)
end
