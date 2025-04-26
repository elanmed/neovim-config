local remaps = {}
local keys = {}
local tbl = {}
local screen = {}
local os = {}
local dev = {}
local notify = {}

-- sugar to avoid magic 0s
local curr = {
  buffer = 0,
  window = 0,
  namespace = 0,
}

--- @param vim_cmd string
--- @return function
keys.vim_cmd_cb = function(vim_cmd)
  return function() vim.cmd(vim_cmd) end
end

--- @param mode 'n' | 'v' | 'i'
--- @param keys_to_send string
keys.send_keys = function(mode, keys_to_send)
  local modeToExpanded = {
    ["n"] = "normal",
    ["i"] = "insert",
    ["v"] = "visual",
  }
  vim.cmd(modeToExpanded[mode] .. "! " .. keys_to_send)

  -- local keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
  -- vim.api.nvim_feedkeys(keys, "n", false)
end

--- @param table table
--- @param target_value any
--- @return boolean
tbl.contains_value = function(table, target_value)
  for _, value in pairs(table) do
    if value == target_value then
      return true
    end
  end
  return false
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

--- more reliable version of vim.print
--- @param input table
--- @return string
tbl.dump = function(input)
  if type(input) == "table" then
    local str = "{ "
    for key, value in pairs(input) do
      if type(key) ~= "number" then key = '"' .. key .. '"' end
      str = str .. "[" .. key .. "] = " .. tbl.dump(value)
    end
    return str .. "} "
  else
    return tostring(input)
  end
end

--- @param table table
--- @return number
tbl.size = function(table)
  local count = 0
  for _ in pairs(table) do
    count = count + 1
  end
  return count
end

screen.has_split = function()
  local screen_cols = vim.opt.columns
  local window_cols = vim.api.nvim_win_get_width(curr.window)
  return screen_cols ~= window_cols
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

  if type(content) == "table" then
    local formatted_content = ""
    for _, item in pairs(content) do
      formatted_content = formatted_content .. " " .. (type(content) == "table" and tbl.dump(item) or tostring(item))
    end
    file:write("[LOG] " .. formatted_content .. "\n")
  else
    file:write("[LOG] " .. (type(content) == "table" and tbl.dump(content) or tostring(content)) .. "\n")
  end

  file:close()
end

--- @param message string
--- @param level "error" | "warn" | "doing" | "toggle_on" | "toggle_off"
notify.notify = function(message, level)
  local level_to_hl_group = {
    error = "NotifyError",
    warn = "NotifyWarning",
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
  notify.notify(message, "info")
end

--- @param message string
notify.warn = function(message)
  notify.notify(message, "warn")
end

--- @param message string
notify.error = function(message)
  notify.notify(message, "error")
end

--- @param message string
notify.toggle_on = function(message)
  notify.notify(message, "toggle_on")
end

--- @param message string
notify.toggle_off = function(message)
  notify.notify(message, "toggle_off")
end

return {
  keys = keys,
  tbl = tbl,
  remaps = remaps,
  screen = screen,
  curr = curr,
  os = os,
  dev = dev,
  notify = notify,
}
