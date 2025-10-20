local h = require "helpers"

--- @param mark_name string
local function get_global_mark_info(mark_name)
  local mark = vim.api.nvim_get_mark(mark_name, {})
  if mark[1] == 0 and mark[2] == 0 and mark[3] == 0 and mark[4] == "" then
    return nil
  end
  return { row = mark[1], bufnr = mark[3], }
end

--- @param mark_name string
local function get_buffer_mark_row(mark_name)
  local mark = vim.api.nvim_buf_get_mark(0, mark_name)
  if mark[1] == 0 and mark[2] == 0 then
    return nil
  end
  return mark[1]
end

local local_marks = ("abcdefghijklmnopqrstuvwxyz")
local global_marks = local_marks:upper()
for letter in (global_marks .. local_marks):gmatch "." do
  vim.fn.sign_define(letter, { text = letter, texthl = "Mark", })
end

--- @param bufnr number
local function refresh_mark_signs(bufnr)
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end

  local group = ""
  vim.fn.sign_unplace(group, { buffer = bufnr, })

  for letter in (global_marks .. local_marks):gmatch "." do
    if get_buffer_mark_row(letter) then
      local id = letter:byte() * 100
      local lnum = unpack(vim.api.nvim_buf_get_mark(bufnr, letter))
      vim.fn.sign_place(id, group, letter, bufnr, { lnum = lnum, priority = 10, })
    end
  end
end

local function set_mark(letter)
  vim.api.nvim_buf_set_mark(0, letter, vim.fn.line ".", 0, {})
  refresh_mark_signs(0)
  h.notify.doing(("Set mark %s to line %s"):format(letter, vim.fn.line "."))
end

local function del_mark(letter)
  vim.api.nvim_buf_del_mark(0, letter)
  refresh_mark_signs(0)
  h.notify.doing(("Deleting mark %s"):format(letter))
end

vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function(args)
    refresh_mark_signs(args.buf)
  end,
})

vim.keymap.set("n", "<leader>me", function()
  refresh_mark_signs(0)
  h.notify.doing "Refreshing marks"
end, { desc = "Refresh the mark signs", })

vim.keymap.set("n", "<leader>mg", function()
  for letter in global_marks:gmatch "." do
    local global_mark_info = get_global_mark_info(letter)
    if not global_mark_info then
      set_mark(letter)
      return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    if global_mark_info.bufnr == bufnr then
      if global_mark_info.row == vim.fn.line "." then
        del_mark(letter)
      else
        set_mark(letter)
      end
      return
    end
  end
end, { desc = "Set a global mark for the buffer", })

vim.keymap.set("n", "<leader>ml", function()
  for letter in local_marks:gmatch "." do
    local mark_row = get_buffer_mark_row(letter)
    if not mark_row then
      set_mark(letter)
      return
    end

    if mark_row == vim.fn.line "." then
      del_mark(letter)
      return
    end
  end
end, { desc = "Set a local mark for the buffer", })

--- @param direction "next"|"prev"
local function navigate_mark(direction)
  --- @type number[]
  local mark_row_list = {}
  for letter in (global_marks .. local_marks):gmatch "." do
    local mark_row = get_buffer_mark_row(letter)
    if mark_row then
      table.insert(mark_row_list, mark_row)
    end
  end

  table.sort(mark_row_list, function(a, b)
    if direction == "next" then
      return b > a
    else
      return b < a
    end
  end)

  for _, mark_row in ipairs(mark_row_list) do
    local row_condition = (function()
      if direction == "next" then
        return mark_row > vim.fn.line "."
      end
      return mark_row < vim.fn.line "."
    end)()

    if row_condition then
      vim.api.nvim_win_set_cursor(0, { mark_row, 0, })
      return
    end
  end

  if #mark_row_list == 0 then return end
  local mark_row = mark_row_list[1]
  vim.api.nvim_win_set_cursor(0, { mark_row, 0, })
end

vim.keymap.set("n", "]a", function() navigate_mark "next" end, { desc = "Navigate to the next mark in the buffer", })
vim.keymap.set("n", "[a", function() navigate_mark "prev" end, { desc = "Navigate to the prev mark in the buffer", })

vim.keymap.set("n", "<leader>md", function()
  local deleted = false
  for letter in (global_marks .. local_marks):gmatch "." do
    if get_buffer_mark_row(letter) then
      vim.api.nvim_buf_del_mark(0, letter)
      deleted = true
    end
  end
  if deleted then
    h.notify.doing "Deleted marks"
  else
    h.notify.doing "No marks in the buffer"
  end

  refresh_mark_signs(0)
end, { desc = "Delete the alphabetic marks for the buffer", })

vim.keymap.set("n", "<leader>mD", function()
  vim.cmd "delmarks a-zA-Z"
  refresh_mark_signs(0)
  h.notify.doing "Deleted all global marks"
end, { desc = "Delete all global marks", })

vim.keymap.set("n", "m", function()
  local char = vim.fn.getcharstr()
  vim.schedule(function() refresh_mark_signs(0) end)
  return "m" .. char
end, { nowait = true, expr = true, desc = "m", })

local function smooth_scroll(direction)
  local lines = math.floor((vim.o.lines - 1) / 2) - 1
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

local function smooth_scroll_cb(direction)
  return function() smooth_scroll(direction) end
end

vim.keymap.set({ "n", "v", }, "<C-d>", smooth_scroll_cb "j", { desc = "Smooth-scroll a half-page down", })
vim.keymap.set({ "n", "v", }, "<C-u>", smooth_scroll_cb "k", { desc = "Smooth-scroll a half-page up", })
