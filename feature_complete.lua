-- remap leader before importing remaps that use it
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require "shared.options"
require "shared.remaps"
require "shared.user_commands"
require "shared.quickfix_list"
require "feature_complete"
