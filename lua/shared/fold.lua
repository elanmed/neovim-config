vim.opt.foldlevelstart = 99
vim.opt.foldcolumn = "1"
vim.opt.fillchars = {
  foldclose = "+",
  foldopen = "-",
  foldsep = " ",
  foldinner = " ",
}

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    -- automatically set to treesitter in `ftplugin/*.lua`
    vim.schedule(function()
      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "v:lua.FoldExpr()"
    end)
  end,
})

--- @param lnum number
local function next_non_blank_line(lnum)
  local num_lines = vim.fn.line "$"
  local curr = lnum + 1
  while curr <= num_lines do
    if vim.fn.getline(curr):match "%S+" then
      return curr
    end
    curr = curr + 1
  end
  return -2
end

--- @param lnum number
local function indent_level(lnum)
  local shiftwidth = vim.api.nvim_get_option_value("shiftwidth", {})
  return tostring(math.floor(vim.fn.indent(lnum) / shiftwidth))
end

-- https://learnvimscriptthehardway.stevelosh.com/chapters/49.html
_G.FoldExpr = function()
  local lnum = vim.v.lnum
  local line = vim.fn.getline(lnum)
  if line:match "^%s*$" then
    return "-1"
  end

  local curr_indent = indent_level(lnum)
  local next_indent = indent_level(next_non_blank_line(lnum))

  if next_indent > curr_indent then
    return ">" .. next_indent
  else
    return curr_indent
  end
end
