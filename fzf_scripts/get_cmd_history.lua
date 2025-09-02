assert(arg[1], "Missing arg1: `servername`")
local servername = arg[1]

local chan = vim.fn.sockconnect("pipe", servername, { rpc = true, })

--- @type number | nil
local num_cmd_history = vim.rpcrequest(chan, "nvim_call_function", "histnr", { "cmd", })
if num_cmd_history == nil then return vim.fn.chanclose(chan) end

for i = 1, math.min(num_cmd_history, 15) do
  local item = vim.rpcrequest(chan, "nvim_call_function", "histget", { "cmd", i * -1, })
  if item == "" then goto continue end
  io.write(item .. "\n")

  ::continue::
end
vim.fn.chanclose(chan)
