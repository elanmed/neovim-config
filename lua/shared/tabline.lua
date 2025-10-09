vim.opt.showtabline = 2
vim.opt.tabline = "%!v:lua.Tabline()"

local get_tab_section = function()
  local tabs = vim.api.nvim_list_tabpages()
  if #tabs == 1 then return "" end
  local curr_tab = vim.api.nvim_get_current_tabpage()
  return table.concat({ "%#Cursor#", curr_tab, "%#TabLine#", }, " ")
end

local get_buf_section = function()
  local alt_bufnr = vim.fn.bufnr "#"
  if not vim.api.nvim_buf_is_valid(alt_bufnr) then
    return "#"
  end
  local alt_bufname = vim.api.nvim_buf_get_name(alt_bufnr)
  local dirname = vim.fs.basename(vim.fs.dirname(alt_bufname))
  local basename = vim.fs.basename(alt_bufname)
  return "#" .. vim.fs.joinpath(dirname, basename)
end

_G.Tabline = function()
  return table.concat({ get_tab_section(), get_buf_section(), }, " ")
end
