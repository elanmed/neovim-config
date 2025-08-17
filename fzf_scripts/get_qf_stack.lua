assert(arg[1], "Missing arg1: `servername`")
local servername = arg[1]

local h = require "helpers"

local chan = vim.fn.sockconnect("pipe", servername, { rpc = true, })
--- @type number
local qf_count = vim.rpcrequest(chan, "nvim_call_function", "getqflist", { { nr = "$", }, }).nr

if qf_count == 0 then
  h.print_with_flush "Quickfix stack is empty!"
  vim.fn.chanclose(chan)
  return
end

for i = 1, qf_count do
  --- @type table

  local qf_list_info = vim.rpcrequest(
    chan,
    "nvim_call_function",
    "getqflist",
    { { nr = i, all = true, }, }
  )
  local source_entry = ("%s| Title: %s | Size: %s | First item: %s"):format(
    qf_list_info.nr,
    qf_list_info.title,
    qf_list_info.size,
    qf_list_info.items[1].text
  )
  h.print_with_flush(source_entry)
end

vim.fn.chanclose(chan)
