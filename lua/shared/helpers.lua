local M = {}

M.remaps = {}

local function map(mode, shortcut, command, opts)
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

  M.remaps[#M.remaps + 1] = table.concat({ formatted_mode, formatted_shortcut, formatted_command, desc, },
    string.rep(" ", 3))
end

M.dump = function(o)
  if type(o) == "table" then
    local s = "{ "
    for k, v in pairs(o) do
      if type(k) ~= "number" then k = '"' .. k .. '"' end
      s = s .. "[" .. k .. "] = " .. M.dump(v)
    end
    return s .. "} "
  else
    return tostring(o)
  end
end

M.has_split = function()
  local function unsafe_has_split()
    return vim.api.nvim_win_get_width(0) ~= vim.api.nvim_get_option "columns"
  end

  local status, retval = pcall(unsafe_has_split)
  if status then return retval else return false end
end

M.maybe_close_split = function(direction)
  if not M.has_split() then return end
  vim.cmd("wincmd " .. direction)
  vim.cmd "q"
end

M.user_cmd_cb = function(user_cmd)
  return function() vim.cmd(user_cmd) end
end

M.nmap = function(shortcut, command, opts)
  map("n", shortcut, command, opts)
end

M.imap = function(shortcut, command, opts)
  map("i", shortcut, command, opts)
end

M.vmap = function(shortcut, command, opts)
  map("v", shortcut, command, opts)
end

M.is_mac = function()
  return vim.fn.has "macunix" == 1
end

M.table_contains_value = function(table, target_value)
  for _, value in pairs(table) do
    if value == target_value then
      return true
    end
  end
  return false
end

M.table_contains_key = function(table, target_key)
  for key in pairs(table) do
    if key == target_key then
      return true
    end
  end
  return false
end

M.send_normal_keys = function(keys)
  vim.api.nvim_command("normal! " .. keys)

  -- local keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
  -- vim.api.nvim_feedkeys(keys, "n", false)

  -- or async
  -- vim.api.nvim_input("<c-w>" .. direction)
  -- vim.defer_fn(cb, 0)
end

-- http://lua-users.org/wiki/SplitJoin
M.split = function(str, delim)
  local outResults = {}
  local theStart = 1
  local theSplitStart, theSplitEnd = string.find(str, delim,
    theStart)
  while theSplitStart do
    table.insert(outResults, string.sub(str, theStart, theSplitStart - 1))
    theStart = theSplitEnd + 1
    theSplitStart, theSplitEnd = string.find(str, delim, theStart)
  end
  table.insert(outResults, string.sub(str, theStart))
  return outResults
end

return vim.tbl_extend("error", M, {
  set = vim.opt,
  let = vim.g,
  map = map,
})
