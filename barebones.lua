-- remap leader before importing remaps that use it
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require "helpers".require_dir "shared"
require "barebones"
