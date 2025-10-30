assert(arg[1], "Missing arg1: `servername`")
local servername = arg[1]
assert(arg[2], "Missing arg2: `cmd`")
local cmd = arg[2]
assert(arg[3], "Missing arg3: `winnr`")
local winnr = tonumber(arg[3])
assert(arg[4], "Missing arg4: `bufnr`")
local bufnr = tonumber(arg[4])

local chan = vim.fn.sockconnect("pipe", servername, { rpc = true, })
-- vim.rpcrequest(chan, "nvim_command", cmd)
vim.rpcrequest(chan, "nvim_exec_lua", [[
  local winnr, bufnr, cmd = ...
  vim.api.nvim_win_call(winnr, function()
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd(cmd)
    end)
  end)
]], { winnr, bufnr, cmd, })

vim.fn.chanclose(chan)
