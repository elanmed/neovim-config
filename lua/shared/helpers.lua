local function map(mode, shortcut, command, opts)
  vim.keymap.set(
    mode,
    shortcut,
    command,
    vim.tbl_extend("force", { noremap = true, silent = true, nowait = true }, opts or {})
  )
end

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

M.pcall_cb = function(call)
  return function() pcall(call) end
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

return vim.tbl_extend("error", M, {
  set = vim.opt,
  let = vim.g,
  map = map,
})
