assert(arg[1], "Missing arg1: `servername`")
assert(arg[2], "Missing arg2: `selected`")

local servername = arg[1]
local selected = arg[2]
local mark = vim.trim(selected):sub(1, 1)

pcall(function()
  local chan = vim.fn.sockconnect("pipe", servername, { rpc = true, })
  vim.rpcrequest(chan, "nvim_exec_lua", ([[vim.cmd 'delmarks %s']]):format(mark), {})
  vim.fn.chanclose(chan)
end)
