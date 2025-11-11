vim.keymap.set("i", "<Cr>", function()
  local current_line = vim.api.nvim_get_current_line()
  local patterns = {
    "%s*local%s+function%(%s*%)%s*$",
    "%s*function%(%s*%)%s*$",
    "%s+do%s*$",
    "%s+then%s*$",
  }
  local has_match = false
  for _, pattern in ipairs(patterns) do
    if current_line:match(pattern) then
      has_match = true
      break
    end
  end

  if not has_match then return "<Cr>" end
  if current_line:match "end%s*$" then return "<Cr>" end

  return "\r" .. "end<C-o>O"
end, { expr = true, buffer = true, })
