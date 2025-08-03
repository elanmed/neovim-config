local cwd = arg[1]
assert(cwd)

local rel_path = arg[2]
assert(rel_path)


local frecency_algo = require "fzf-lua-frecency.algo"
local abs_path = vim.fs.joinpath(cwd, rel_path)
frecency_algo.update_file_score(abs_path, { update_type = "remove", })
