local h = require "shared.helpers"

-- remap leader before importing remaps that use it
h.map("", "<space>", "<nop>")
h.let.mapleader = " "
h.let.maplocalleader = " "

require "shared.options"
require "shared.remaps"
require "shared.user_commands"
require "feature_complete"

-- TODO:
-- merge conflicts with fugitive
