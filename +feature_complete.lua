local h = require "shared.helpers"

-- remap leader before importing remaps that use it
h.map("", "<space>", "<nop>")
h.let.mapleader = " "
h.let.maplocalleader = " "

-- for bootstrapping
local packer_status_ok = pcall(require, "packer")
if not packer_status_ok then
  require "feature_complete.plugins.packer"
  return
end

require "feature_complete"
require "shared.options"
require "shared.remaps"

-- TODO:
-- merge conflicts with fugitive
-- better git blame

-- to generate highlight_groups.txt
-- redir > highlight_groups.txt | silent hi | redir END
