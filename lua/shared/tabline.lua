local h = require "helpers"
vim.o.showtabline = 2
vim.o.tabline = "%!v:lua.Tabline()"

local unnamed_buf_name = "[unnamed]"
local terminal_buf_name = "[terminal]"

--- @param bufnr number
local get_name = function(bufnr)
  if vim.bo[bufnr].buftype == "terminal" then return terminal_buf_name end

  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname == "" then return unnamed_buf_name end

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
  if not vim.api.nvim_buf_is_valid(bufnr) then return "" end

  if get_name(vim.fn.bufnr "%") == unnamed_buf_name then return "" end
  if get_name(vim.fn.bufnr "%") == terminal_buf_name then return "" end
  if get_name(bufnr) == get_name(vim.fn.bufnr "%") then return "" end

  return "%#TabLine#ALT " .. get_name(bufnr)
end

_G.Tabline = function()
  return table.concat({
    get_tab_section(),
    h.str.pad(get_curr_buf_section(), { min_len = 80, side = "right", }),
    get_alt_buf_section(),
  }, " ")
end

