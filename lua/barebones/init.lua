local h = require "shared.helpers"

-- remap leader before importing remaps that use it
h.map("", "<space>", "<nop>")
h.let.mapleader = " "

require "barebones.options"
require "barebones.remaps"

require "shared.options"
require "shared.remaps"
