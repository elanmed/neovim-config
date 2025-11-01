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

local ns_id = vim.api.nvim_create_namespace "seek"
local lower_case = ("abcdefghijklmnopqrstuvwxyz")
local labels = vim.split(lower_case .. lower_case:upper(), "")

local get_key = function()
  local ok, char = pcall(vim.fn.getchar)
  if not ok then return { type = "error", char = nil, } end
  local escape = 27
  if char == escape then return { type = "error", char = nil, } end
  return { type = "success", char = vim.fn.nr2char(char), }
end

local seek = function()
  local first_key = get_key()
  if first_key.type == "error" then
    h.notify.doing "Exiting after key 1"
    return
  end

  local second_key = get_key()
  if second_key.type == "error" then
    h.notify.doing "Exiting after key 2"
    return
  end

  local keys = first_key.char .. second_key.char

  --- @class Match
  --- @field row_0i number
  --- @field col_0i number
  --- @field label string

  --- @type Match[]
  local matches = {}

  local curr_line_0i = vim.fn.line "." - 1
  local next_line_0i = curr_line_0i + 1
  local end_line_0i = vim.fn.line "w$" - 1

  local lines = vim.api.nvim_buf_get_lines(0, next_line_0i, end_line_0i + 1, false)
  for line_idx_1i, line in ipairs(lines) do
    local plain = true

    local idx_1i = 1
    while true do
      local start_pos_1i, end_pos_1i = line:find(keys, idx_1i, plain)
      if not start_pos_1i then break end

      local row_0i = line_idx_1i - 1
      row_0i = row_0i + next_line_0i

      local start_pos_adjusted_1i = start_pos_1i + 2
      local start_pos_adjusted_0i = start_pos_adjusted_1i - 1
      local label = labels[#matches + 1]
      table.insert(matches, { line = line, row_0i = row_0i, col_0i = start_pos_adjusted_0i, label = label, })

      idx_1i = end_pos_1i + 1
    end
  end

  if #matches == 0 then
    h.notify.error "No matches"
    return
  end

  if #matches == 1 then
    local match = matches[1]
    local row_1i = match.row_0i + 1
    vim.api.nvim_win_set_cursor(0, { row_1i, match.col_0i, })
  end

  for _, match in ipairs(matches) do
    vim.api.nvim_buf_set_extmark(0, ns_id, match.row_0i, match.col_0i, {
      virt_text = { { match.label, "CurSearch", }, },
      virt_text_pos = "overlay",
    })
  end

  -- extmarks need to update
  vim.schedule(function()
    local label_key = get_key()
    if label_key.type == "error" then
      h.notify.error "No label selected"
      vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
      return
    end

    for _, match in ipairs(matches) do
      if label_key.char == match.label then
        local row_1i = match.row_0i + 1
        local col_adjusted_0i = match.col_0i - 2
        vim.api.nvim_win_set_cursor(0, { row_1i, col_adjusted_0i, })
        vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
        return
      end
    end

    h.notify.error "Invalid label selected"
    vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
  end)
end
vim.keymap.set("n", "<leader>s", seek)
