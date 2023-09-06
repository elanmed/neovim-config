local h = require "shared.helpers"

local harpoon = require "harpoon"
local harpoon_mark = require "harpoon.mark"
local harpoon_ui = require "harpoon.ui"

harpoon.setup({})

h.nmap("<leader>aa", harpoon_mark.add_file)
h.nmap("<leader>at", harpoon_ui.toggle_quick_menu)
h.nmap("<leader>an", harpoon_ui.nav_next)
h.nmap("<leader>ap", harpoon_ui.nav_prev)
