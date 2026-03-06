vim.o.showtabline = 2
vim.o.laststatus = 2
vim.o.tabline = "%!v:lua.Tabline()"
vim.o.statusline = "%!v:lua.Statusline()"

--- @param bufnr number
local get_name = function(bufnr)
  if vim.bo[bufnr].buftype == "terminal" then return "[terminal]" end

  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname == "" then return "[unnamed]" end

  local dirname = vim.fs.basename(vim.fs.dirname(bufname))
  local basename = vim.fs.basename(bufname)
  return vim.fs.joinpath(dirname, basename)
end

local get_tab_section = function()
  local tabs = vim.api.nvim_list_tabpages()
  if #tabs == 1 then return "" end
  local curr_tab = vim.api.nvim_get_current_tabpage()
  return table.concat({ "%#Search#", curr_tab, "%#TabLine#", }, " ")
end

--- @param buf_symbol "%" | "#"
local get_buf_section = function(buf_symbol)
  local bufnr = vim.fn.bufnr(buf_symbol)
  if not vim.api.nvim_buf_is_valid(bufnr) then return "" end

  if buf_symbol == "%" then
    return "%#TabLineTitle#EDIT: %#TabLineSel#" .. get_name(bufnr)
  elseif buf_symbol == "#" then
    return "ALT: " .. get_name(bufnr)
  end
end

_G.Tabline = function()
  return table.concat({ get_tab_section(), get_buf_section "%", }, " ")
end

_G.Statusline = function()
  if vim.fn.bufnr "#" == vim.fn.bufnr "%" then return "" end
  return get_buf_section "#"
end
