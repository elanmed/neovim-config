package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/nvim/?.lua"
local h = require("shared.helpers")

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
  vim.api.nvim_command(string.format("cdo s/%s/%s", opts.fargs[1], opts.fargs[2]))
  vim.api.nvim_command("cfdo update")
end, { nargs = "*" })

h.nmap("<leader>ir", ":FindAndReplace ", { silent = false })
