package.path = package.path .. ";../?.lua"
local h = require("elan.helpers")

require("nvim-tree").setup({
	hijack_cursor = true,
	view = {
		width = 40,
		mappings = {
			list = {
				{ key = "Y", action = "copy_path" },
				{ key = "<CR>", action = "tabnew" },
				{ key = "s", action = "" },
			},
		},
	},
	renderer = {
		highlight_opened_files = "all",
		highlight_git = true,
	},
	diagnostics = {
		enable = true,
		show_on_dirs = false,
		icons = {
			hint = "",
			info = "",
			warning = "",
			error = "",
		},
	},
	git = {
		ignore = false,
	},
})

h.nmap("<leader>rb", ":NvimTreeToggle<CR>")
h.nmap("<leader>re", ":NvimTreeFindFile<CR>")
