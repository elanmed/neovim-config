local remaps = {}
local keys = {}
local tbl = {}
local screen = {}
local os = {}
local dev = {}

-- sugar to avoid magic numbers
local curr = {
  buffer = 0,
  window = 0,
  namespace = 0,
}

--- @param mode string|string[]
--- @param shortcut string
--- @param command string|function
--- @param opts? vim.keymap.set.Opts
local function remap(mode, shortcut, command, opts)
  opts = opts or {}
  vim.keymap.set(
    mode,
    shortcut,
    command,
    vim.tbl_extend("force", { noremap = true, silent = true, nowait = true, }, opts)
  )
  local desc = opts.desc or ""
  local formatted_mode = mode == "" and " " or mode

  local function get_string_len(str)
    if str == "∆" or str == "˚" then return 1 end
    return #str
  end

  local formatted_shortcut = shortcut .. string.rep(" ", 10 - get_string_len(shortcut))
  local formatted_command = type(command) == "string" and command or "Function"

  remaps[#remaps + 1] = table.concat({ formatted_mode, formatted_shortcut, formatted_command, desc, },
    string.rep(" ", 3))
end

--- returns a function that calls vim.cmd(user_cmd)
--- @param user_cmd string
--- @return function
keys.vim_cmd_cb = function(user_cmd)
  return function() vim.cmd(user_cmd) end
end

--- @param modes string[]
--- @param shortcut string
--- @param command string|function
--- @param opts? vim.keymap.set.Opts
keys.map = function(modes, shortcut, command, opts)
  for _, mode in pairs(modes) do
    remap(mode, shortcut, command, opts)
  end
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
  local screen_cols = vim.o.columns
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
    vim.notify("Error opening file!", vim.log.levels.ERROR)
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

return {
  set = vim.opt,
  let = vim.g,
  keys = keys,
  tbl = tbl,
  remaps = remaps,
  screen = screen,
  curr = curr,
  os = os,
  dev = dev,
}
