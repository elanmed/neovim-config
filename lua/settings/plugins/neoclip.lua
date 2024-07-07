local h = require "shared.helpers"
local neoclip = require "neoclip"
local telescope = require "telescope"

neoclip.setup({
  history = 25,
  keys = {
    telescope = {
      i = {
        paste = "<f1>", -- unbind <C-p>, but this doesn't accept nil or ""
      },
    },
  },
})
h.nmap("<leader>yo", telescope.extensions.neoclip.default)
h.vmap("<leader>yo", telescope.extensions.neoclip.default)
h.nmap("<leader>yp", [[""p]])
