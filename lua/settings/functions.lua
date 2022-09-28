package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/nvim/?.lua"
local h = require("shared.helpers")

local function split(s, delimiter)
  local result = {}
  for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
    table.insert(result, match)
  end
  return result
end

-- two ways to call lua fns in vim

--[[ function elan.sample_fn() ]]
--[[ 	print("sample_fn") ]]
--[[ end ]]
--[[ h.nmap("", ":lua elan.sample_fn()<cr>") ]]

--[[ function _G.sample_fn() ]]
--[[ 	print("sample_fn") ]]
--[[ end ]]
--[[ h.nmap("", "v:lua.sample_fn()<cr>") ]]

vim.api.nvim_create_user_command("FindAndReplace", function(opts)
  local args = split(opts.args, " ")
  vim.api.nvim_command(string.format("cdo s/%s/%s", args[1], args[2]))
end, { nargs = "*" })

h.nmap("<leader>ir", ":FindAndReplace ", { silent = false })
