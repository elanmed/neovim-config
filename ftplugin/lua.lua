-- %s -> whitespace character
-- * -> zero or more of the previous item
-- + -> one or more of the previous item
-- [ ] -> set of characters, one of which must match
-- %w -> alphanumeric character
-- _ -> literal underscore
-- . -> any character outside a set, literal dot inside a set
-- : -> literal colon
-- %b -> balanced match of the two enclosed characters
-- () -> the pair to balance, here parentheses
-- $ -> end of the line

local end_of_block_patterns = {
  "%s*function%s+[%w_.:]+%s*%b()%s*$",
  "%s*function%s*%b()%s*$",
  "%s+do%s*$",
  "%s+then%s*$",
}

vim.keymap.set("i", "<Cr>", function()
  local current_line = vim.api.nvim_get_current_line()

  local has_match = false
  for _, pattern in ipairs(end_of_block_patterns) do
    if current_line:match(pattern) then
      has_match = true
      break
    end
  end

  if not has_match then
    return "<Cr>"
  end

  return "\r" .. "end<C-o>O"
end, { expr = true, buffer = true })
