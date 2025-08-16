local cwd = arg[1]
assert(cwd, "Missing arg1: `cwd`")

local rel_path = arg[2]
assert(rel_path, "Missing arg2: `rel_path`")

local abs_path = vim.fs.joinpath(cwd, rel_path)
require "fzf-lua-frecency.algo".update_file_score(abs_path, { update_type = "remove", })
