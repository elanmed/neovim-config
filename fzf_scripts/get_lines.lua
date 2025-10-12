assert(arg[1], "Missing arg1: `servername`")
local servername = arg[1]

assert(arg[2], "Missing arg2: `bufnr`")
local bufnr = tonumber(arg[2])

local chan = vim.fn.sockconnect("pipe", servername, { rpc = true, })

--- @type string[] | nil
local lines = vim.rpcrequest(chan, "nvim_buf_get_lines", bufnr, 0, -1, false)
if not lines then return vim.fn.chanclose(chan) end

for idx, line in ipairs(lines) do
  io.write(("%s|%s\n"):format(idx, line))
end

vim.fn.chanclose(chan)
