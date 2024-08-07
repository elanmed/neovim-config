local h = require "shared.helpers"

-- remap leader before importing remaps that use it
h.map("", "<space>", "<nop>")
h.let.mapleader = " "
h.let.maplocalleader = " "


-- for bootstrapping
local packer_status_ok = pcall(require, "packer")
if not packer_status_ok then
  require "settings.plugins.packer"
  return
end

require "settings.plugins"
require "settings.functions"
require "settings.remaps"
require "settings.options"

require "shared.options"
require "shared.remaps"

-- TODO:
-- merge conflicts, with diffview

-- to generate highlight_groups.txt
-- redir > highlight_groups.txt | silent hi | redir END
