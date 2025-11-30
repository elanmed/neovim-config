assert(arg[1], "Missing arg1: `servername`")
local servername = arg[1]

local chan = vim.fn.sockconnect("pipe", servername, { rpc = true, })

for i = 9, 1, -1 do
  --- @type string | nil
  local reg = vim.rpcrequest(chan, "nvim_call_function", "getreg", { tostring(i), })
  if reg then
    io.write(("%d|%s\n"):format(i, reg:gsub("\n", "NEWLINE")))
  end
end
vim.fn.chanclose(chan)
