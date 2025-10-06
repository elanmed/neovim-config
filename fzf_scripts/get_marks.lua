assert(arg[1], "Missing arg1: `servername`")
local servername = arg[1]

local chan = vim.fn.sockconnect("pipe", servername, { rpc = true, })

--- @class MarkListEntry
--- @field file string
--- @field mark string -- prefixed with '

--- @type MarkListEntry[] | nil
local mark_list = vim.rpcrequest(chan, "nvim_call_function", "getmarklist", {})

--- @type string | nil
local cwd = vim.rpcrequest(chan, "nvim_call_function", "getcwd", {})

vim.fn.chanclose(chan)
if cwd == nil then return end
if mark_list == nil then return end

local num_marks = 0
for _, mark_entry in pairs(mark_list) do
  local name = mark_entry.mark:sub(2, 2)
  if not name:match "[A-Z]" then goto continue end
  local rel_file = vim.fs.relpath(cwd, mark_entry.file)
  io.write(("%s|%s"):format(name, rel_file) .. "\n")
  num_marks = num_marks + 1
  ::continue::
end

if num_marks == 0 then
  io.write("No marks!" .. "\n")
end
