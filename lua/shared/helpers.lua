local remaps = {}
local keys = {}
local tbl = {}
local screen = {}

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

keys.user_cmd_cb = function(user_cmd)
  return function() vim.cmd(user_cmd) end
end

keys.map = function(modes, shortcut, command, opts)
  for _, mode in pairs(modes) do
    remap(mode, shortcut, command, opts)
  end
end

keys.is_mac = function()
  return vim.fn.has "macunix" == 1
end

keys.send_normal_keys = function(normal_keys)
  vim.api.nvim_command("normal! " .. normal_keys)

  -- local keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
  -- vim.api.nvim_feedkeys(keys, "n", false)

  -- or async
  -- vim.api.nvim_input("<c-w>" .. direction)
  -- vim.defer_fn(cb, 0)
end


tbl.table_contains_value = function(table, target_value)
  for _, value in pairs(table) do
    if value == target_value then
      return true
    end
  end
  return false
end

tbl.table_contains_key = function(table, target_key)
  for key in pairs(table) do
    if key == target_key then
      return true
    end
  end
  return false
end

tbl.dump = function(o)
  if type(o) == "table" then
    local s = "{ "
    for k, v in pairs(o) do
      if type(k) ~= "number" then k = '"' .. k .. '"' end
      s = s .. "[" .. k .. "] = " .. tbl.dump(v)
    end
    return s .. "} "
  else
    return tostring(o)
  end
end

screen.has_split = function()
  return vim.api.nvim_win_get_width(0) ~= vim.api.nvim_get_option "columns"
end


return {
  set = vim.opt,
  let = vim.g,
  keys = keys,
  tbl = tbl,
  remaps = remaps,
  screen = screen,
}
