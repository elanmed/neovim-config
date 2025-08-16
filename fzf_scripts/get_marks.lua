assert(arg[1], "Missing arg1: `servername`")

local function print_with_flush(str)
  io.write(str)
  io.write "\n"
  io.flush()
end

local servername = arg[1]

--- @class MarkListEntry
--- @field file string
--- @field mark string -- prefixed with '

local chan = vim.fn.sockconnect("pipe", servername, { rpc = true, })
--- @type MarkListEntry[]
local mark_list = vim.rpcrequest(chan, "nvim_exec_lua", "return vim.fn.getmarklist()", {})
vim.fn.chanclose(chan)

local global_marks = ("abcdefghijklmnopqrstuvwxyz"):upper()

for _, mark in pairs(mark_list) do
  local name = mark.mark:sub(2, 2)
  if not global_marks:find(name) then goto continue end
  print_with_flush(("%s|%s"):format(name, mark.file))
  ::continue::
end
