assert(arg[1], "Missing arg1: `servername`")
assert(arg[2], "Missing arg2: `selected`")

local servername = arg[1]
local mark = arg[2]

local chan = vim.fn.sockconnect("pipe", servername, { rpc = true, })
vim.rpcrequest(chan, "nvim_del_mark", mark)
vim.fn.chanclose(chan)
