local function map(mode, shortcut, command)
	vim.api.nvim_set_keymap(mode, shortcut, command, { noremap = true, silent = true }) -- silent prevents from populating the command bar
end

local function nmap(shortcut, command)
	map("n", shortcut, command)
end

local function imap(shortcut, command)
	map("i", shortcut, command)
end

local function vmap(shortcut, command)
	map("v", shortcut, command)
end

local helpers = {
	set = vim.opt,
	let = vim.g,
	nmap = nmap,
	imap = imap,
	vmap = vmap,
	map = vim.api.nvim_set_keymap,
}
return helpers
