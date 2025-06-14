local h = require "helpers"

-- remap leader before importing remaps that use it
vim.g.mapleader = " "
vim.g.maplocalleader = " "

h.require_dir "shared"
require "barebones"
