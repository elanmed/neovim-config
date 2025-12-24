local tbl = {}
local str = {}
local _os = {}
local dev = {}
local notify = {}
local utils = {}

local vimscript_true = 1
local vimscript_false = 0

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

--- @param ... any[]
tbl.extend = function(...)
  local result = {}
  for _, list in ipairs { ..., } do
    vim.list_extend(result, list)
  end
  return result
end

_os.is_linux = function()
  return vim.fn.has "macunix" == vimscript_false
end

--- @param content any
dev.log = function(content)
  local file = io.open("log.txt", "a")
  if not file then
    notify.error "Error opening file!"
    return
  end
  file:write(vim.inspect(content) .. "\n")
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
  vim.fn.timer_start(1500, function()
    if vim.fn.mode() ~= "t" then vim.cmd [[normal! :<Esc>]] end
  end)
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
utils.require_dir = function(dir)
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
--- @param fallback T
--- @return T
utils.if_nil = function(val, fallback)
  if val == nil then
    return fallback
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

utils.rotate_registers = function()
  for i = 9, 1, -1 do
    vim.fn.setreg(tostring(i), vim.fn.getreg(tostring(i - 1)))
  end
end

--- @param val string
utils.set_and_rotate = function(val)
  vim.fn.setreg("", val)
  vim.fn.setreg("+", val)
  notify.doing("Setting the unnamed and + registers to: `" .. val .. "`")
  utils.rotate_registers()
end

--- @class PadOpts
--- @field val string | number
--- @field max_len number
--- @field side 'left' | 'right'
--- @param opts PadOpts
str.pad = function(opts)
  if #tostring(opts.val) >= opts.max_len then
    return tostring(opts.val)
  end

  local num_spaces = opts.max_len - #tostring(opts.val)
  if opts.side == "left" then
    return string.rep(" ", num_spaces) .. tostring(opts.val)
  end
  return tostring(opts.val) .. string.rep(" ", num_spaces)
end

return {
  tbl = tbl,
  os = _os,
  dev = dev,
  notify = notify,
  vimscript_true = vimscript_true,
  vimscript_false = vimscript_false,
  utils = utils,
  str = str,
}
