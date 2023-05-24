local function map(mode, shortcut, command, opts)
  vim.keymap.set(
    mode,
    shortcut,
    command,
    vim.tbl_extend("force", { noremap = true, silent = true, nowait = true }, opts or {})
  )
end

local M = {}

M.nmap = function(shortcut, command, opts)
  map("n", shortcut, command, opts)
end

M.imap = function(shortcut, command, opts)
  map("i", shortcut, command, opts)
end

M.vmap = function(shortcut, command, opts)
  map("v", shortcut, command, opts)
end

M.get_visual = function()
  local _, ls, cs = unpack(vim.fn.getpos('v'))
  local _, le, ce = unpack(vim.fn.getpos('.'))
  return vim.api.nvim_buf_get_text(0, ls - 1, cs - 1, le - 1, ce, {})
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

-- TODO: add to metatable
M.split = function(str, pat)
  -- emtpy string breaks the fn
  assert(pat ~= "")
  local t = {}
  local fpat = "(.-)" .. pat
  local last_end = 1
  local s, e, cap = str:find(fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
      table.insert(t, cap)
    end
    last_end = e + 1
    s, e, cap = str:find(fpat, last_end)
  end
  if last_end <= #str then
    cap = str:sub(last_end)
    table.insert(t, cap)
  end
  return t
end

-- for strings that are only spaces, trims down to empty string
-- TODO: add to metatable
M.trim = function(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- TODO: add to metatable
M.len = function(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

-- TODO: add to metatable
M.tbl_clone = function(original)
  local copy = {}
  for key, value in pairs(original) do
    copy[key] = value
  end
  return copy
end

return vim.tbl_extend("error", M, {
  set = vim.opt,
  let = vim.g,
  map = map,
})
