local h = require "shared.helpers"

-- remap leader before importing remaps that use it
h.map({ "n", "i", "v", }, "<space>", "<nop>")
h.let.mapleader = " "
h.let.maplocalleader = " "
vim.cmd "colorscheme darkblue"

require "shared.options"
require "shared.remaps"
require "shared.user_commands"
require "barebones"
