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

local local_marks = ("abcdefghijklmnopqrstuvwxyz")
local global_marks = local_marks:upper()

--- @param letters string
--- @param hl string
local function define_mark_signs(letters, hl)
  for letter in letters:gmatch "." do
    vim.fn.sign_define(letter, { text = letter, texthl = hl, })
  end
end

define_mark_signs(global_marks, "DiagnosticInfo")
define_mark_signs(local_marks, "DiagnosticInfo")

--- @param bufnr number
local function refresh_mark_signs(bufnr)
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end

  local group = ""
  vim.fn.sign_unplace(group, { buffer = bufnr, })

  for letter in (global_marks .. local_marks):gmatch "." do
    local is_buffer_mark_set = not is_buffer_mark_unset(letter)
    if is_buffer_mark_set then
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

vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function(args)
    refresh_mark_signs(args.buf)
  end,
})

vim.keymap.set("n", "<leader>mg", function()
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

  if next_avail_mark then set_mark(next_avail_mark) end
end, { desc = "Set a global mark for the buffer", })

vim.keymap.set("n", "<leader>ml", function()
  local next_avail_mark = nil
  for letter in local_marks:gmatch "." do
    if is_buffer_mark_unset(letter) then
      next_avail_mark = letter
      break
    end
  end

  if next_avail_mark then set_mark(next_avail_mark) end
end, { desc = "Set a local mark for the buffer", })

vim.keymap.set("n", "<leader>md", function()
  for letter in (global_marks .. local_marks):gmatch "." do
    local is_buffer_mark_set = not is_buffer_mark_unset(letter)

    if is_buffer_mark_set then
      vim.api.nvim_buf_del_mark(0, letter)
      h.notify.doing("Deleted mark " .. letter)
    end
  end

  refresh_mark_signs(0)
end, { desc = "Delete the alphabetic marks for the buffer", })

vim.keymap.set("n", "<leader>mD", function()
  vim.cmd "delmarks a-zA-Z"
  refresh_mark_signs(0)
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

local function smooth_scroll_cb(direction)
  return function() smooth_scroll(direction) end
end

vim.keymap.set({ "n", "v", }, "<C-d>", smooth_scroll_cb "j", { desc = "Smooth-scroll half-page down", })
vim.keymap.set({ "n", "v", }, "<C-u>", smooth_scroll_cb "k", { desc = "Smooth-scroll half-page up", })
