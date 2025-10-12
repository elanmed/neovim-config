local h = require "helpers"
vim.o.showtabline = 2
vim.o.tabline = "%!v:lua.Tabline()"

local max_len = math.floor(vim.o.columns / 2)

local get_tab_section = function()
  local tabs = vim.api.nvim_list_tabpages()
  if #tabs == 1 then return "" end
  local curr_tab = vim.api.nvim_get_current_tabpage()
  return table.concat({ "%#Search#", curr_tab, "%#TabLine#", }, " ")
end

--- @param buf_type "curr"|"alt"
local get_buf_section = function(buf_type)
  local buf_symbol = buf_type == "alt" and "#" or "%"
  local formatted_buf_symbol = buf_type == "alt" and "# " or "%% "
  local bufnr = vim.fn.bufnr(buf_symbol)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    if buf_type == "alt" then
      return ""
    elseif buf_type == "curr" then
      return h.str.pad { max_len = max_len, side = "right", val = formatted_buf_symbol, }
    end
  end

  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local dirname = vim.fs.basename(vim.fs.dirname(bufname))
  local basename = vim.fs.basename(bufname)
  local buf_section = "%#TabLineTitle#" .. formatted_buf_symbol .. "%#TabLineSel#" .. vim.fs.joinpath(dirname, basename)

  if buf_type == "alt" then
    return buf_section
  elseif buf_type == "curr" then
    return h.str.pad { max_len = max_len, side = "right", val = buf_section, }
  end
end

_G.Tabline = function()
  return table.concat({ get_tab_section(), get_buf_section "curr", get_buf_section "alt", }, " ")
end
