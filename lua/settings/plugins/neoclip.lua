local h = require "shared.helpers"

local neoclip = require "neoclip"

neoclip.setup()
h.nmap("<leader>y", [[<cmd>lua require("telescope").extensions.neoclip.default()<cr>]])
h.vmap("<leader>y", [[<cmd>lua require("telescope").extensions.neoclip.default()<cr>]])
