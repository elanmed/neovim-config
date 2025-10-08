vim.opt.clipboard = "unnamedplus" -- os clipboard
vim.opt.cursorline = true
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.confirm = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.termguicolors = true -- needed for modern themes
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.signcolumn = "yes"
vim.opt.linebreak = true
vim.opt.breakindent = true -- wrapped lines will be properly indented
vim.opt.spelllang = "en_us"
vim.opt.spell = false -- TODO: look into
vim.opt.expandtab = true -- use spaces in tabs
vim.opt.tabstop = 2 -- number of columns in a tab
vim.opt.softtabstop = 2 -- number of spaces to delete when deleting a tab
vim.opt.shiftwidth = 2 -- number of spaces to insert/delete when in insert mode
-- disable vim backups
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.laststatus = 0
vim.opt.ruler = false
vim.opt.showcmd = false
vim.opt.suffixesadd = { ".tsx", ".jsx", ".ts", ".js", }
vim.opt.completeopt = { "menuone", "noselect", "fuzzy", }
vim.opt.wildmode = "noselect"
vim.opt.wildoptions = "fuzzy"

vim.opt.foldlevelstart = 99
vim.opt.foldcolumn = "1"
vim.opt.fillchars = {
  foldclose = ">",
  foldopen = "v",
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

_G.FoldExpr = function()
  local lnum = vim.v.lnum
  local line = vim.fn.getline(lnum)
  if line:match "^%s*$" then
    return "-1"
  end

  if line:match "^import.*^" then
    return "1"
  end

  local curr_indent = indent_level(lnum)
  local next_indent = indent_level(next_non_blank_line(lnum))

  if next_indent > curr_indent then
    return ">" .. next_indent
  else
    return curr_indent
  end
end
