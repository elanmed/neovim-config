local h = require "shared.helpers"
require "scrollbar".setup()

h.keys.map({ "n", "v", "i", }, "<C-u>", function()
  if vim.fn.line "$" == vim.fn.line "." then
    return "M"
  else
    return "<C-u>"
  end
end, { expr = true, })

h.keys.map({ "n", "v", "i", }, "<C-d>", function()
  if vim.fn.line "." == 1 then
    return "M"
  else
    return "<C-d>"
  end
end, { expr = true, })
