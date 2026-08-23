local h = require "helpers"
local a = require "async"

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

local curr_buf_prefix = "%#TabLineTitle#EDIT %#TabLineSel#"
local get_curr_buf_section = function()
  local bufnr = vim.fn.bufnr "%"
  if not vim.api.nvim_buf_is_valid(bufnr) then return "" end

  return get_name(bufnr)
end

local alt_buf_prefix = "%#TabLine#ALT "
local get_alt_buf_section = function()
  local bufnr = vim.fn.bufnr "#"
  if not vim.api.nvim_buf_is_valid(bufnr) then return "" end

  if get_name(vim.fn.bufnr "%") == unnamed_buf_name then return "" end
  if get_name(vim.fn.bufnr "%") == terminal_buf_name then return "" end
  if get_name(bufnr) == get_name(vim.fn.bufnr "%") then return "" end

  return get_name(bufnr)
end

_G.Tabline = function()
  local section_len = math.min(40, math.floor(vim.o.columns / 3))

  local truncated_buf_section = h.str.truncate(
    get_curr_buf_section(),
    { max_len = section_len, side = "left", }
  )

  local padded_buf_section = h.str.pad(
    truncated_buf_section,
    { min_len = section_len * 1.5, side = "right", }
  )

  local truncated_alt_section = h.str.truncate(
    get_alt_buf_section(),
    { max_len = section_len, side = "left", }
  )

  return table.concat({
    get_tab_section(),
    curr_buf_prefix .. padded_buf_section,
    alt_buf_prefix .. truncated_alt_section,
  }, " ")
end


local branch_cache = nil
local get_branch = a.make_async(function()
  local out = a.await(h.utils.vim_system { "git", "rev-parse", "--absolute-git-dir", })
  if out.code ~= 0 then return nil end

  if out.stdout == nil then return nil end

  local git_dir = vim.trim(out.stdout)
  local head = vim.fn.readfile(git_dir .. "/HEAD")
  if #head == 0 then return nil end

  local ref = head[1]:match "ref: refs/heads/(.+)"
  if ref == nil then return nil end

  return ref
end)

local spawn = a.make_spawn(function()
  branch_cache = a.await(get_branch())
end)
spawn()

vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("InvalidateBranchCache", { clear = true, }),
  pattern = "GitHeadChanged",
  callback = a.make_spawn(function()
    branch_cache = a.await(get_branch())
  end),
})

_G.Statusline = function()
  local branch = "[no branch]"
  if branch_cache ~= nil then
    branch = branch_cache
  end

  return "%#TabLine#BRANCH: " .. branch
end

vim.o.showtabline = 2
vim.o.tabline = "%!v:lua.Tabline()"
vim.o.statusline = "%!v:lua.Statusline()"
