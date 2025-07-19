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

vim.keymap.set("n", "gm", function()
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

vim.keymap.set("n", "dgm", function()
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

vim.keymap.set("n", "dGM", function()
  vim.cmd "delmarks A-Z"
  h.notify.doing "Deleted all global marks"
end, { desc = "Delete all global marks", })

vim.keymap.set("n", "dA", function()
  vim.cmd "delmarks a-zA-Z"
  h.notify.doing "Deleted all marks"
end, { desc = "Delete all marks", })
