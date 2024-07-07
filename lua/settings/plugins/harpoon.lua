local h = require "shared.helpers"

local harpoon = require "harpoon"
local harpoon_mark = require "harpoon.mark"
local harpoon_ui = require "harpoon.ui"

harpoon.setup({})

h.nmap("<leader>aa", harpoon_mark.add_file, { desc = "Add a file to harpoon" })
h.nmap("<leader>at", harpoon_ui.toggle_quick_menu, { desc = "Toggle the harpoon menu" })
h.nmap("<leader>an", harpoon_ui.nav_next, { desc = "Go to the next harpoon item" })
h.nmap("<leader>ap", harpoon_ui.nav_prev, { desc = "Go to the previous harpoon item" })
