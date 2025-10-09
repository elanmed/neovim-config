assert(arg[1], "Missing arg1: `servername`")
local servername = arg[1]

local chan = vim.fn.sockconnect("pipe", servername, { rpc = true, })


--- @type number[] | nil
local buf_list = vim.rpcrequest(chan, "nvim_list_bufs")
if buf_list == nil then return end

--- @type string | nil
local cwd = vim.rpcrequest(chan, "nvim_call_function", "getcwd", {})
if cwd == nil then return end

local num_bufs = 0
for _, bufnr in ipairs(buf_list) do
  --- @type string | nil
  local bufname = vim.rpcrequest(chan, "nvim_buf_get_name", bufnr)
  if bufname == nil then goto continue end
  if bufname == "" then goto continue end

  --- @type boolean | nil
  local is_loaded = vim.rpcrequest(chan, "nvim_buf_is_loaded", bufnr)
  if not is_loaded then goto continue end

  --- @type boolean | nil
  local listed = vim.rpcrequest(chan, "nvim_get_option_value", "buflisted", { buf = bufnr, })
  if not listed then goto continue end

  local rel_path = vim.fs.relpath(cwd, bufname)

  num_bufs = num_bufs + 1
  io.write(("%s|%s\n"):format(num_bufs, rel_path))
  ::continue::
end

if num_bufs == 0 then
  io.write("No bufs" .. "\n")
end

vim.fn.chanclose(chan)
