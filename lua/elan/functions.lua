package.path = package.path .. ";../?.lua"
local h = require("elan.helpers")

--[[ function elan.sample_fn() ]]
--[[ 	print("sample_fn") ]]
--[[ end ]]
--[[ h.nmap("", ":lua elan.sample_fn()<cr>") ]]

vim.api.nvim_create_user_command("FindAndReplace", function(opts)
	local args = h.split(opts.args, " ")
	vim.api.nvim_command(string.format("cdo s/%s/%s", args[1], args[2]))
end, { nargs = "*" })

h.nmap("<leader>ee", ":FindAndReplace ", { silent = false })
