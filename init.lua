local h = require("settings.helpers")

-- remap leader before importing remaps that use it
h.map("", "<space>", "<nop>")
h.let.mapleader = " "


-- for bootstrapping
local packer_status_ok = pcall(require, "packer")
if not packer_status_ok then
  require("settings.plugins.packer")
  return
end

require("settings.plugins")
require("settings.remaps")
require("settings.options")
require("settings.functions")
