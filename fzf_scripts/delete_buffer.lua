assert(arg[1], "Missing arg1: `servername`")
assert(arg[2], "Missing arg2: `bufnr`")

local servername = arg[1]
local bufnr = arg[2]

local chan = vim.fn.sockconnect("pipe", servername, { rpc = true, })
vim.rpcrequest(chan, "nvim_cmd", { cmd = "bdelete", args = { tostring(bufnr), }, }, {})
vim.fn.chanclose(chan)
