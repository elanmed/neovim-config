local h = require "helpers"
vim.o.showtabline = 2
vim.o.tabline = "%!v:lua.Tabline()"

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

local get_curr_buf_section = function()
  local bufnr = vim.fn.bufnr "%"
  if not vim.api.nvim_buf_is_valid(bufnr) then return "" end

  return "%#TabLineTitle#EDIT %#TabLineSel#" .. get_name(bufnr)
end

local get_alt_buf_section = function()
  local bufnr = vim.fn.bufnr "#"
  if bufnr == vim.fn.bufnr "%" then return "" end
  if not vim.api.nvim_buf_is_valid(bufnr) then return "" end

  return "%#TabLineTitle#ALT %#TabLine#" .. get_name(bufnr)
end

_G.Tabline = function()
  return table.concat({
    get_tab_section(),
    h.str.pad(get_curr_buf_section(), { min_len = 60, side = "right", }),
    " %#TabLine#| ",
    get_curr_buf_section(),
  }, " ")
end
  if not vim.api.nvim_buf_is_valid(bufnr) then return "" end

  return "%#TabLineTitle#ALT %#TabLine#" .. get_name(bufnr)
end

_G.Tabline = function()
  return table.concat({
    get_tab_section(),
    h.str.pad(get_curr_buf_section(), { min_len = 60, side = "right", }),
    " %#TabLine#| ",
    get_curr_buf_section(),
  }, " ")
end

