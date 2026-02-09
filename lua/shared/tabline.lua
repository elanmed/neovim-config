vim.o.showtabline = 2
vim.o.tabline = "%!v:lua.Tabline()"

local get_tab_section = function()
  local tabs = vim.api.nvim_list_tabpages()
  if #tabs == 1 then return "" end
  local curr_tab = vim.api.nvim_get_current_tabpage()
  return table.concat({ "%#Search#", curr_tab, "%#TabLine#", }, " ")
end

local get_buf_section = function()
  local bufnr = vim.fn.bufnr "#"
  if not vim.api.nvim_buf_is_valid(bufnr) then return "" end

  local name = (function()
    if vim.bo[bufnr].buftype == "terminal" then return "[terminal]" end

    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if bufname == "" then return "[unnamed]" end

    local dirname = vim.fs.basename(vim.fs.dirname(bufname))
    local basename = vim.fs.basename(bufname)
    return vim.fs.joinpath(dirname, basename)
  end)()
  return "%#TabLineTitle#ALT %#TabLineSel#" .. name
end

_G.Tabline = function()
  local alt_section = (function()
    if vim.fn.bufnr "#" == vim.fn.bufnr "%" then
      return ""
    end
    return get_buf_section()
  end)()

  return table.concat({ get_tab_section(), alt_section, }, " ")
end
