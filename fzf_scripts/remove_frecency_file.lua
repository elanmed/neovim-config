assert(arg[1], "Missing arg1: `servername`")
local servername = arg[1]
assert(arg[2], "Missing arg2: `rel_path`")
local rel_path = arg[2]

local chan = vim.fn.sockconnect("pipe", servername, { rpc = true, })
local cwd = vim.rpcrequest(chan, "nvim_call_function", "getcwd", {})


local abs_path = vim.fs.joinpath(cwd, rel_path)
require "fzf-lua-frecency.algo".update_file_score(abs_path, { update_type = "remove", })
