assert(arg[1], "Missing arg1: `cwd`")
assert(arg[2], "Missing arg2: `rel_path`")

local cwd = arg[1]
local rel_path = arg[2]

local abs_path = vim.fs.joinpath(cwd, rel_path)
require "fzf-lua-frecency.algo".update_file_score(abs_path, { update_type = "remove", })
