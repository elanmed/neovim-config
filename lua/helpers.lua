local keys = {}
local tbl = {}
local os = {}
local dev = {}
local notify = {}

local vimscript_true = 1
local vimscript_false = 0

--- @param vim_cmd string
--- @return function
keys.vim_cmd_cb = function(vim_cmd)
  return function() vim.cmd(vim_cmd) end
end

--- @param mode 'n' | 'v' | 'i'
--- @param keys_to_send string
keys.send_keys = function(mode, keys_to_send)
  local modeToExpanded = { ["n"] = "normal", ["i"] = "insert", ["v"] = "visual", }
  vim.cmd(("%s! %s"):format(modeToExpanded[mode], keys_to_send))
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
  local base_lua_path = vim.fs.joinpath(vim.fn.stdpath "config", "lua") -- ~/.config/nvim/lua/
  local glob_path = vim.fs.joinpath(base_lua_path, dir, "*.lua") -- ~/.config/nvim/lua/feature_complete/plugins/*.lua
  local paths_str = vim.fn.glob(glob_path)
  local paths_tbl = vim.split(paths_str, "\n")
  for _, path in pairs(paths_tbl) do
    -- convert absolute filename to relative
    -- ~/.config/nvim/lua/feature_complete/plugins/*.lua -> feature_complete/plugins/*
    -- local relfilename = path:gsub(base_lua_path, ""):gsub(".lua", "")
    local relfilename = vim.fs.relpath(base_lua_path, path):gsub(".lua", "")
    require(relfilename)
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
}
