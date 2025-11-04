vim.o.foldlevelstart = 99
vim.o.foldcolumn = "1"
vim.opt.fillchars = {
  foldclose = "+",
  foldopen = "-",
  foldsep = " ",
  foldinner = " ",
}

vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function()
    vim.schedule(function()
      -- automatically set to treesitter in `ftplugin/*.lua`
      vim.o.foldmethod = "expr"
      vim.o.foldexpr = "v:lua.FoldExpr()"
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
  return tostring(math.floor(vim.fn.indent(lnum) / vim.o.shiftwidth))
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
