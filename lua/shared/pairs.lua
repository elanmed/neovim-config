local h = require "helpers"

local left_to_right_pair = {
  ["("] = ")",
  ["{"] = "}",
  ["["] = "]",
  ["<"] = ">",
  ["`"] = "`",
  ["'"] = "'",
  ['"'] = '"',
}

local opening_pairs = { "(", "{", "[", "<", }
local closing_pairs = { ")", "}", "]", ">", }
local same_pairs = { [[`]], [[']], [["]], }

--- @param typed_char string
local function skip_or_insert_char(typed_char)
  return function()
    local col_zero_indexed = vim.api.nvim_win_get_cursor(0)[2]
    local col_one_indexed = col_zero_indexed + 1
    local line = vim.api.nvim_get_current_line()
    local char_right = line:sub(col_one_indexed, col_one_indexed)

    if char_right == typed_char then
      return "<right>"
    end

    local should_insert_pair =
        char_right == nil or
        char_right == "" or
        vim.tbl_contains(closing_pairs, char_right) or
        char_right:match "%s"

    if vim.tbl_contains(opening_pairs, typed_char) then
      if should_insert_pair then
        return typed_char .. left_to_right_pair[typed_char] .. "<left>"
      end

      return typed_char
    elseif vim.tbl_contains(closing_pairs, typed_char) then
      return typed_char
    elseif vim.tbl_contains(same_pairs, typed_char) then
      if should_insert_pair then
        return typed_char .. typed_char .. "<left>"
      end

      return typed_char
    end
  end
end

for _, char in pairs(h.tbl.extend(same_pairs, opening_pairs, closing_pairs)) do
  vim.keymap.set("i", char, skip_or_insert_char(char), { expr = true, })
end

vim.keymap.set("i", "<bs>", function()
  local col_zero_indexed = vim.api.nvim_win_get_cursor(0)[2]
  local col_one_indexed = col_zero_indexed + 1
  local line = vim.api.nvim_get_current_line()
  local char = line:sub(col_one_indexed, col_one_indexed)
  if char == "" then return "<bs>" end

  local char_left = line:sub(col_one_indexed - 1, col_one_indexed - 1)
  if left_to_right_pair[char_left] ~= char then return "<bs>" end
  return "<right><bs><bs>"
end, { expr = true, })
