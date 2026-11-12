local left_to_right_pair = {
  ["("] = ")",
  ["{"] = "}",
  ["["] = "]",
  ["<"] = ">",
  ["'"] = [[']],
  ["\""] = [["]],
  ["`"] = [[`]],
}

local backspace = function()
  local line
  local char_idx_0i
  if vim.fn.mode() == "c" then
    line = vim.fn.getcmdline()
    char_idx_0i = vim.fn.getcmdpos() - 1
  else
    line = vim.api.nvim_get_current_line()
    char_idx_0i = vim.api.nvim_win_get_cursor(0)[2]
  end
  local char_idx_1i = char_idx_0i + 1

  if char_idx_1i == 1 then
    return "<bs>"
  end
  local char = line:sub(char_idx_1i, char_idx_1i)

  local char_left_idx = char_idx_1i - 1
  local char_left = line:sub(char_left_idx, char_left_idx)

  if left_to_right_pair[char_left] == char then
    return "<right><bs><bs>"
  end

  if char_idx_1i == 2 then
    return "<bs>"
  end
  local char_two_left_idx = char_idx_1i - 2
  local char_two_left = line:sub(char_two_left_idx, char_two_left_idx)

  if left_to_right_pair[char_two_left] == char_left then
    return "<bs><bs>"
  end

  return "<bs>"
end

vim.keymap.set({ "i", "c" }, ";u", "()<left>")
vim.keymap.set({ "i", "c" }, ";v", "[]<left>")
vim.keymap.set({ "i", "c" }, ";c", "{}<left>")
vim.keymap.set({ "i", "c" }, ";a", "<><left>")
vim.keymap.set({ "i", "c" }, ";d", [[""<left>]])
vim.keymap.set({ "i", "c" }, ";s", [[''<left>]])
vim.keymap.set({ "i", "c" }, ";t", [[``<left>]])

vim.keymap.set({ "i", "c" }, "<C-d>", "<bs>")
vim.keymap.set({ "i", "c" }, "<bs>", backspace, { expr = true })
