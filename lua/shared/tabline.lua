vim.opt.showtabline = 2
vim.opt.tabline = "%!v:lua.Tabline()"

local get_tab_section = function()
  local tabs = vim.api.nvim_list_tabpages()
  if #tabs == 1 then return "" end
  local curr_tab = vim.api.nvim_get_current_tabpage()
  return table.concat({ "%#Search#", curr_tab, "%#TabLine#", }, " ")
end

--- @param buf_type "curr"|"alt"
local get_buf_section = function(buf_type)
  local buf_symbol = buf_type == "alt" and "#" or "%"
  local formatted_buf_symbol = buf_type == "alt" and "Alt: " or "Curr: "
  local bufnr = vim.fn.bufnr(buf_symbol)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    if buf_type == "alt" then return "" end
    return formatted_buf_symbol
  end
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local dirname = vim.fs.basename(vim.fs.dirname(bufname))
  local basename = vim.fs.basename(bufname)
  return "%#TabLineTitle#" .. formatted_buf_symbol .. "%#TabLineSel#" .. vim.fs.joinpath(dirname, basename)
end

_G.Tabline = function()
  return table.concat({ get_buf_section "curr", "%=", get_buf_section "alt", "%=", "%=", }, " ")
end
