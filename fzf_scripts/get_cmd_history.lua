assert(arg[1], "Missing arg1: `servername`")
local servername = arg[1]

local h = require "helpers"
local chan = vim.fn.sockconnect("pipe", servername, { rpc = true, })
--- @type number
local num_cmd_history = vim.rpcrequest(chan, "nvim_call_function", "histnr", { "cmd", })

for i = 1, math.min(num_cmd_history, 15) do
  local item = vim.rpcrequest(chan, "nvim_call_function", "histget", { "cmd", i * -1, })
  if item == "" then goto continue end
  h.print_with_flush(item)

  ::continue::
end
vim.fn.chanclose(chan)
