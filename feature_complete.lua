local h = require "shared.helpers"

-- remap leader before importing remaps that use it
vim.keymap.set({ "", }, "<space>", "<nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require "shared.options"
require "shared.remaps"
require "shared.user_commands"
require "feature_complete"
