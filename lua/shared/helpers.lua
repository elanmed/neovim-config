local remaps = {}

local function map(mode, shortcut, command, opts)
  opts = opts or {}
  vim.keymap.set(
    mode,
    shortcut,
    command,
    vim.tbl_extend("force", { noremap = true, silent = true, nowait = true }, opts)
  )
  local desc = opts.desc or ""
  local formatted_mode = mode == "" and " " or mode

  local function get_string_len(str)
    if str == "∆" or str == "˚" then return 1 end
    return #str
  end

  local formatted_shortcut = shortcut .. string.rep(" ", 10 - get_string_len(shortcut))
  local formatted_command = type(command) == "string" and command or "Function"

  remaps[#remaps + 1] = table.concat({ formatted_mode, formatted_shortcut, formatted_command, desc }, string.rep(" ", 3))
end

vim.api.nvim_create_user_command("PrintRemaps", function()
  print("Custom remaps:")
  for _, val in pairs(remaps) do
    print(val)
  end
end, { nargs = "*" })

local M = {}

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
  return vim.fn.has("macunix") == 1
end

M.table_contains = function(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

M.send_keys = function(keys)
  vim.api.nvim_command("normal! " .. keys)
end

return vim.tbl_extend("error", M, {
  set = vim.opt,
  let = vim.g,
  map = map,
})
