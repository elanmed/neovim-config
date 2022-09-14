local configs = require("nvim-treesitter.configs")

configs.setup({
	ensure_installed = "all",
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false, -- prevent vim highlight from interfering with treesitter
	},
	indent = { enable = true },
	rainbow = {
		enable = true,
		extended_mode = false,
	},
	autotag = {
		enable = true,
	},
	context_commentstring = {
		enable = true,
		enable_autocmd = false,
	},
})
