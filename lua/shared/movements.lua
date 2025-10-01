local h = require "helpers"

--- @param mark_name string
local function is_global_mark_unset(mark_name)
  local mark = vim.api.nvim_get_mark(mark_name, {})
  return mark[1] == 0 and mark[2] == 0 and mark[3] == 0 and mark[4] == ""
end

--- @param mark_name string
local function is_buffer_mark_unset(mark_name)
  local mark = vim.api.nvim_buf_get_mark(0, mark_name)
  return mark[1] == 0 and mark[2] == 0
end

local global_marks = ("abcdefghijklmnopqrstuvwxyz"):upper()

vim.keymap.set("n", "<leader>la", function()
  local function set_mark(letter)
    vim.api.nvim_buf_set_mark(0, letter, vim.fn.line ".", 0, {})
    h.notify.doing(("Set global mark %s to line %s"):format(letter, vim.fn.line "."))
  end

  for letter in global_marks:gmatch "." do
    local is_buffer_mark_set = not is_buffer_mark_unset(letter)

    if is_buffer_mark_set then
      set_mark(letter)
      return
    end
  end

  local next_avail_mark = nil
  for letter in global_marks:gmatch "." do
    if is_global_mark_unset(letter) then
      next_avail_mark = letter
      break
    end
  end

  if next_avail_mark == nil then
    h.notify.error "No global marks available!"
    return
  end
  set_mark(next_avail_mark)
end, { desc = "Set a global mark for the buffer", })

vim.keymap.set("n", "<leader>ld", function()
  for letter in global_marks:gmatch "." do
    local is_buffer_mark_set = not is_buffer_mark_unset(letter)

    if is_buffer_mark_set then
      vim.api.nvim_del_mark(letter)
      h.notify.doing("Deleted global mark " .. letter)
      return
    end
  end
  h.notify.error "No global mark in the buffer"
end, { desc = "Delete a global mark for the buffer", })

vim.keymap.set("n", "<leader>lD", function()
  vim.cmd "delmarks A-Z"
  h.notify.doing "Deleted all global marks"
end, { desc = "Delete all global marks", })

local function smooth_scroll(direction)
  local lines = math.floor((vim.api.nvim_win_get_height(0)) / 2) - 1
  local count = 0
  local function step()
    if count < lines then
      vim.cmd("normal! " .. direction)
      count = count + 1
      vim.defer_fn(step, 10)
    end
  end
  step()
end

vim.keymap.set({ "n", "v", }, "<C-d>", function()
  smooth_scroll "j"
end, { desc = "Smooth-scroll half-page down", })
vim.keymap.set({ "n", "v", }, "<C-u>", function()
  smooth_scroll "k"
end, { desc = "Smooth-scroll half-page up", })
