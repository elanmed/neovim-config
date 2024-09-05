local h = require "shared.helpers"
local telescope = require "telescope"

h.nmap("<leader>ye", telescope.extensions.neoclip.default, { desc = "Open neoclip" })
h.nmap("<leader>yp", [[""p]], { desc = "Paste the last item selected from neoclip" })

return {
  "AckslD/nvim-neoclip.lua",
  commit = "709c97f",
  opts = {
    history = 25,
    keys = {
      telescope = {
        i = {
          paste = "<f1>", -- unbind <C-p>, but this doesn't accept nil or ""
        },
      },
    },
  }
}
