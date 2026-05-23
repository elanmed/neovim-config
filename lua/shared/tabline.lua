local h = require "helpers"
vim.o.showtabline = 2
vim.o.tabline = "%!v:lua.Tabline()"
vim.o.statusline = "%!v:lua.Statusline()"

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
    h.str.pad(get_curr_buf_section(), { min_len = math.min(100, vim.o.columns), side = "right", }),
    get_alt_buf_section(),
  }, " ")
end


local get_branch = function()
  local out = vim.system { "git", "rev-parse", "--absolute-git-dir", }:wait()
  if out.code ~= 0 then return nil end
  if out.stdout == nil then return nil end

  local git_dir = vim.trim(out.stdout)
  local head = vim.fn.readfile(git_dir .. "/HEAD")
  if #head == 0 then return nil end

  local ref = head[1]:match "ref: refs/heads/(.+)"
  if ref == nil then return nil end

  return ref
end

local branch_cache = get_branch()

vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("InvalidateBranchCache", { clear = true, }),
  pattern = "GitHeadChanged",
  callback = function()
    branch_cache = get_branch()
  end,
})

_G.Statusline = function()
  local branch = "[no branch]"
  if branch_cache ~= nil then
    branch = branch_cache
  end

  return "%#TabLine#BRANCH: " .. branch
end
