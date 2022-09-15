local h = require("elan.helpers")

-- remap leader before importing remaps that use it
h.map("", "<space>", "<nop>")
h.let.mapleader = " "


local packer_status_ok = pcall(require, "packer")
if not packer_status_ok then
  require("elan.plugins.packer")
  return
end

require("elan.plugins")
require("elan.remaps")
require("elan.options")
require("elan.functions")
