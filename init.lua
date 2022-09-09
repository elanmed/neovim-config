local h = require("elan.helpers")

-- remap leader before importing remaps that use it
h.map("", "<space>", "<nop>", { silent = true })
h.let.mapleader = " "

require("elan.remaps")
require("elan.options")
require("elan.plugins")
require("elan.functions")
