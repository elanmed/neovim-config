assert(arg[1], "Missing arg1: `servername`")
local servername = arg[1]

local h = require "helpers"

--- @class MarkListEntry
--- @field file string
--- @field mark string -- prefixed with '

local chan = vim.fn.sockconnect("pipe", servername, { rpc = true, })
--- @type MarkListEntry[]
local mark_list = vim.rpcrequest(chan, "nvim_call_function", "getmarklist", {})
vim.fn.chanclose(chan)

local global_marks = ("abcdefghijklmnopqrstuvwxyz"):upper()

local num_marks = 0
for _, mark in pairs(mark_list) do
  local name = mark.mark:sub(2, 2)
  if not global_marks:find(name) then goto continue end
  h.print_with_flush(("%s|%s"):format(name, mark.file))
  num_marks = num_marks + 1
  ::continue::
end

if num_marks == 0 then
  h.print_with_flush "No marks!"
end
