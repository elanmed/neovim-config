local h = require "helpers"

local function smooth_scroll(direction)
  local lines = math.floor((vim.o.lines - 1) / 2) - 1
  local count = 0
  local function step()
    if count < lines then
      vim.cmd.normal { direction, bang = true, }
      count = count + 1
      vim.defer_fn(step, 10)
    end
  end
  step()
end

local function smooth_scroll_cb(direction)
  return function() smooth_scroll(direction) end
end

vim.keymap.set({ "n", "v", }, "<C-d>", smooth_scroll_cb "j", { desc = "Smooth-scroll a half-page down", })
vim.keymap.set({ "n", "v", }, "<C-u>", smooth_scroll_cb "k", { desc = "Smooth-scroll a half-page up", })

local function wezterm_cli_move(direction)
  local cmd = "wezterm cli activate-pane-direction " .. direction
  if h.os.is_linux() then
    cmd = "flatpak-spawn --host " .. cmd
  end

  vim.fn.system(cmd)
end

vim.keymap.set("n", "<C-l>", function()
  local prev_win = vim.api.nvim_get_current_win()
  vim.cmd.wincmd "l"
  local curr_win = vim.api.nvim_get_current_win()
  if prev_win == curr_win then
    wezterm_cli_move "Right"
  end
end)

vim.keymap.set("n", "<C-h>", function()
  local prev_win = vim.api.nvim_get_current_win()
  vim.cmd.wincmd "h"
  local curr_win = vim.api.nvim_get_current_win()

  if prev_win == curr_win then
    wezterm_cli_move "Left"
  end
end)
