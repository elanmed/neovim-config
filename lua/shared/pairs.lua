local left_to_right_pair = {
  ["("] = ")",
  ["{"] = "}",
  ["["] = "]",
  ["'"] = [[']],
  ['"'] = [["]],
  ["`"] = [[`]],
}

vim.keymap.set("i", "uu", "()<left>")
vim.keymap.set("i", "vv", "[]<left>")
vim.keymap.set("i", "kk", "{}<left>")
vim.keymap.set("i", "aa", "<><left>")
vim.keymap.set("i", "qq", [[""<left>]])
vim.keymap.set("i", "jj", [[''<left>]])

vim.keymap.set("i", "<bs>", function()
  local char_idx_0i = vim.api.nvim_win_get_cursor(0)[2]
  local char_idx = char_idx_0i + 1

  if char_idx == 1 then return "<bs>" end

  local char_left_idx = char_idx - 1

  if left_to_right_pair[char_left_idx] == left_to_right_pair[char_idx] then return "<right><bs><bs>" end

  if char_idx == 2 then return "<bs>" end
  local char_two_left_idx = char_idx - 2

  if left_to_right_pair[char_two_left_idx] == left_to_right_pair[char_left_idx] then return "<bs><bs>" end

  return "<bs>"
end, { expr = true, })
