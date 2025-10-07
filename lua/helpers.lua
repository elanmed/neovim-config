local keys = {}
local tbl = {}
local os = {}
local dev = {}
local notify = {}
local utils = {}

local vimscript_true = 1
local vimscript_false = 0

--- @param vim_cmd string
--- @return function
keys.vim_cmd_cb = function(vim_cmd)
  return function() vim.cmd(vim_cmd) end
end

--- @param table table
--- @param target_key any
--- @return boolean
tbl.contains_key = function(table, target_key)
  for key in pairs(table) do
    if key == target_key then
      return true
    end
  end
  return false
end

--- @param predicate fun(curr_item, idx: number): boolean
--- @param list table
tbl.filter = function(predicate, list)
  local filtered_list = {}
  for index, val in pairs(list) do
    if (predicate(val, index)) then -- vim.tbl_filter doesn't pass the index
      table.insert(filtered_list, val)
    end
  end
  return filtered_list
end

--- @param predicate fun(curr_item, idx: number): any
--- @param list table
tbl.map = function(predicate, list)
  local mapped_list = {}
  for index, val in pairs(list) do
    -- vim.tbl_map doesn't pass the index
    table.insert(mapped_list, predicate(val, index))
  end
  return mapped_list
end

os.is_linux = function()
  return vim.fn.has "macunix" == vimscript_false
end

--- @param content any
dev.log = function(content)
  local file = io.open("log.txt", "a")
  if not file then
    notify.error "Error opening file!"
    return
  end
  file:write(vim.inspect(content))
  file:write "\n"
  file:close()
end

--- @param message string
--- @param level "error" | "warn" | "doing" | "info" | "toggle_on" | "toggle_off"
local function _notify(message, level)
  local level_to_hl_group = {
    error = "NotifyError",
    info = "NotifyDoing",
    toggle_on = "NotifyToggleOn",
    toggle_off = "NotifyToggleOff",
  }
  local hl_group = level_to_hl_group[level]

  local add_to_history = true
  vim.api.nvim_echo({ { message, hl_group, }, }, add_to_history, {})
end

--- @param message string
notify.doing = function(message)
  _notify(message, "info")
end

--- @param message string
notify.error = function(message)
  _notify(message, "error")
end

--- @param message string
notify.toggle_on = function(message)
  _notify(message, "toggle_on")
end

--- @param message string
notify.toggle_off = function(message)
  _notify(message, "toggle_off")
end

--- @param dir string i.e. "/feature_complete/plugins/"
local require_dir = function(dir)
  local base_lua_path = vim.fs.joinpath(vim.fn.stdpath "config", "lua")
  local glob_path = vim.fs.joinpath(base_lua_path, dir, "*.lua")
  local paths_str = vim.fn.glob(glob_path)
  local paths_tbl = vim.split(paths_str, "\n")
  for _, path in pairs(paths_tbl) do
    local relfilename = vim.fs.relpath(base_lua_path, path):gsub(".lua", "")
    require(relfilename)
  end
end

--- @generic T
--- @param val T | nil
--- @param default_val T
--- @return T
utils.default = function(val, default_val)
  if val == nil then
    return default_val
  end
  return val
end

--- @param try string
--- @param catch string
utils.try_catch = function(try, catch)
  local success, _ = pcall(vim.cmd, try)
  if not success then
    pcall(vim.cmd, catch)
  end
end

return {
  keys = keys,
  tbl = tbl,
  os = os,
  dev = dev,
  notify = notify,
  require_dir = require_dir,
  vimscript_true = vimscript_true,
  vimscript_false = vimscript_false,
  utils = utils,
}
