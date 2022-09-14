local h = require("elan.helpers")

-- remap leader before importing remaps that use it
h.map("", "<space>", "<nop>")
h.let.mapleader = " "

require("elan.plugins")
require("elan.remaps")
require("elan.options")
require("elan.functions")
