local keys = {}
local tbl = {}
local str = {}
local _os = {}
local dev = {}
local notify = {}
local utils = {}

local vimscript_true = 1
local vimscript_false = 0

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


--- @alias DiffRecordType "+"|"-"|"="
--- @alias DiffRecord { type: DiffRecordType, line: string }

--- @param a string[]
--- @param b string[]
--- @return DiffRecord[]
utils.diff = function(a, b)
  --- @param num number
  local max_decimals = function(num)
    local decimals = 2
    local factor = 10 ^ decimals
    return math.floor(num * factor) / factor
  end

  local str_a = table.concat(a, "\n")
  local str_b = table.concat(b, "\n")

  local records = {}
  local start_time = os.clock()
  local indices = vim.text.diff(str_a, str_b, { result_type = "indices", })
  local end_time = os.clock()
  local diff_time = max_decimals((end_time - start_time) * 1000)
  notify.doing(("utils.diff: %ss"):format(diff_time))

  local idx_a = 1
  local idx_b = 1

  for _, hunk in ipairs(indices) do
    local start_a, count_a, start_b, count_b = unpack(hunk)

    while idx_a < start_a do
      table.insert(records, { type = "=", line = a[idx_a], })
      idx_a = idx_a + 1
      idx_b = idx_b + 1
    end

    for i = 1, count_a do
      table.insert(records, { type = "-", line = a[start_a + i - 1], })
    end

    for i = 1, count_b do
      table.insert(records, { type = "+", line = b[start_b + i - 1], })
    end

    idx_a = start_a + count_a
    idx_b = start_b + count_b
  end

  while idx_a <= #a do
    table.insert(records, { type = "=", line = a[idx_a], })
    idx_a = idx_a + 1
  end

  return records
end

return {
  keys = keys,
  tbl = tbl,
  os = _os,
  dev = dev,
  notify = notify,
  require_dir = require_dir,
  vimscript_true = vimscript_true,
  vimscript_false = vimscript_false,
  utils = utils,
  str = str,
}
