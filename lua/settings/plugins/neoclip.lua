local h = require "shared.helpers"
local neoclip = require "neoclip"
local telescope = require "telescope"

neoclip.setup({
  history = 25,
})
h.nmap("<leader>yo", telescope.extensions.neoclip.default)
h.vmap("<leader>yo", telescope.extensions.neoclip.default)
h.nmap("<leader>yp", [[""p]])
