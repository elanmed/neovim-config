local keys = {}
local tbl = {}
local os = {}
local dev = {}
local notify = {}

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
  return vim.fn.has "macunix" == 0
end

--- @param name string
os.file_exists = function(name)
  local file = io.open(name, "r")
  if file == nil then
    return false
  else
    io.close(file)
    return true
  end
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
  if dir:sub(1, 1) ~= "/" then
    dir = "/" .. dir
  end

  if dir:sub(-1) ~= "/" then
    dir = dir .. "/"
  end

  local base_lua_path = vim.fn.stdpath "config" .. "/lua" -- ~/.config/nvim/lua/
  local glob_path = base_lua_path .. dir .. "*.lua"       -- ~/.config/nvim/lua/feature_complete/plugins/*.lua
  for _, path in pairs(vim.split(vim.fn.glob(glob_path), "\n")) do
    -- convert absolute filename to relative
    -- ~/.config/nvim/lua/feature_complete/plugins/*.lua -> feature_complete/plugins/*
    local relfilename = path:gsub(base_lua_path, ""):gsub(".lua", "")
    require(relfilename)
  end
end

return { keys = keys, tbl = tbl, os = os, dev = dev, notify = notify, require_dir = require_dir, }
