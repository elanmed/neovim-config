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
h.nmap("<leader>yt", telescope.extensions.neoclip.default, { desc = "Open neoclip" })
h.vmap("<leader>yt", telescope.extensions.neoclip.default, { desc = "Open neoclip" })
h.nmap("<leader>yp", [[""p]], { desc = "Paste the last item selected from neoclip" })
