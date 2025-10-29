assert(arg[1], "Missing arg1: `servername`")
local servername = arg[1]
assert(arg[2], "Missing arg2: `cmd`")
local cmd = arg[2]

local chan = vim.fn.sockconnect("pipe", servername, { rpc = true, })
vim.rpcrequest(chan, "nvim_command", cmd)
vim.fn.chanclose(chan)
