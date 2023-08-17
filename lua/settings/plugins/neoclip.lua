local h = require "shared/helpers"

local neoclip = require "neoclip"

neoclip.setup({
  keys = {
    telescope = {
      i = {
        paste = '<f1>', -- doesn't accept nil or ''
      },
    },
  },
})
h.nmap("<leader>yo", [[<cmd>lua require("telescope").extensions.neoclip.default()<cr>]])
h.vmap("<leader>yo", [[<cmd>lua require("telescope").extensions.neoclip.default()<cr>]])
h.nmap("<leader>yp", [[""p]])
