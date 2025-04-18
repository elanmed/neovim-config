-- remap leader before importing remaps that use it
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.cmd "colorscheme slate"

require "shared.options"
require "shared.remaps"
require "shared.user_commands"
require "barebones"
