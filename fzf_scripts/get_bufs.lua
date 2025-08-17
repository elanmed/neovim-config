assert(arg[1], "Missing arg1: `servername`")
local servername = arg[1]

local h = require "helpers"
local chan = vim.fn.sockconnect("pipe", servername, { rpc = true, })
--- @type number[]
local buf_list = vim.rpcrequest(chan, "nvim_list_bufs")
--- @type string
local cwd = vim.rpcrequest(chan, "nvim_call_function", "getcwd", {})

for _, buf in pairs(buf_list) do
  local loaded = vim.rpcrequest(chan, "nvim_buf_is_loaded", buf)
  if not loaded then goto continue end

  --- @type string
  local bname = vim.rpcrequest(chan, "nvim_buf_get_name", buf)
  local readable = vim.rpcrequest(chan, "nvim_call_function", "filereadable", { bname, })
  if readable == h.vimscript_false then goto continue end

  if not vim.startswith(bname, cwd) then goto continue end

  h.print_with_flush(vim.fs.relpath(cwd, bname))

  ::continue::
end

vim.fn.chanclose(chan)
