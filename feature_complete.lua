-- remap leader before importing remaps that use it
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require "helpers".utils.require_dir "shared"
require "feature_complete"
vim.g.loaded_netrw = 1
