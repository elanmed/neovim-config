local left_to_right_pair = {
  ["("] = ")",
  ["{"] = "}",
  ["["] = "]",
  ["<"] = ">",
  ["'"] = [[']],
  ['"'] = [["]],
  ["`"] = [[`]],
}

vim.keymap.set("i", ";u", "()<left>")
vim.keymap.set("i", ";v", "[]<left>")
vim.keymap.set("i", ";c", "{}<left>")
vim.keymap.set("i", ";a", "<><left>")
vim.keymap.set("i", ";d", [[""<left>]])
vim.keymap.set("i", ";s", [[''<left>]])
vim.keymap.set("i", ";t", [[``<left>]])

vim.keymap.set("i", "<C-d>", function()
  local char_idx_0i = vim.api.nvim_win_get_cursor(0)[2]
  local char_idx = char_idx_0i + 1
  local line = vim.api.nvim_get_current_line()

  if char_idx == 1 then return "<bs>" end
  local char = line:sub(char_idx, char_idx)

  local char_left_idx = char_idx - 1
  local char_left = line:sub(char_left_idx, char_left_idx)

  if left_to_right_pair[char_left] == char then return "<right><bs><bs>" end

  if char_idx == 2 then return "<bs>" end
  local char_two_left_idx = char_idx - 2
  local char_two_left = line:sub(char_two_left_idx, char_two_left_idx)

  if left_to_right_pair[char_two_left] == char_left then return "<bs><bs>" end

  return "<bs>"
end, { expr = true, })

