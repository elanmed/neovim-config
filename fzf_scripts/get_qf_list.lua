assert(arg[1], "Missing arg1: `servername`")
local servername = arg[1]

local chan = vim.fn.sockconnect("pipe", servername, { rpc = true, })
--- @type table | nil
local qf_list = vim.rpcrequest(chan, "nvim_call_function", "getqflist", { { items = 0, }, })
if qf_list == nil then return vim.fn.chanclose(chan) end

if #qf_list.items == 0 then
  io.write("Quickfix list is empty!" .. "\n")
  vim.fn.chanclose(chan)
  return
end

--- @type string | nil
local cwd = vim.rpcrequest(chan, "nvim_call_function", "getcwd", {})
if cwd == nil then return vim.fn.chanclose(chan) end

for _, entry in pairs(qf_list.items) do
  --- @type string | nil
  local filename = vim.rpcrequest(chan, "nvim_buf_get_name", entry.bufnr)
  if filename == nil then goto continue end

  --- @type string|nil
  local formatted_filename = filename
  if vim.startswith(filename, cwd) then
    formatted_filename = vim.fs.relpath(cwd, filename)
  end

  local source_entry = ("%s|%s|%s|%s"):format(formatted_filename, entry.lnum, entry.col, entry.text)
  io.write(source_entry .. "\n")

  ::continue::
end

vim.fn.chanclose(chan)
