assert(arg[1], "Missing arg1: `servername`")
local servername = arg[1]

local chan = vim.fn.sockconnect("pipe", servername, { rpc = true, })
--- @type string[] | nil
local oldfiles = vim.rpcrequest(chan, "nvim_exec_lua", "return vim.v.oldfiles", {})
if oldfiles == nil then return end

--- @type string | nil
local cwd = vim.rpcrequest(chan, "nvim_call_function", "getcwd", {})
if cwd == nil then return end

vim.fn.chanclose(chan)

for _, oldfile in ipairs(oldfiles) do
  if not vim.startswith(oldfile, cwd) then goto continue end

  io.write(vim.fs.relpath(cwd, oldfile), "\n")
  ::continue::
end
