local h = require "shared.helpers"
local colors = require "settings.plugins.base16"
local harpoon = require "harpoon-core"
local harpoon_mark = require "harpoon-core.mark"
local harpoon_ui = require "harpoon-core.ui"

harpoon.setup({
  menu = {
    width = 100,
    height = 10,
  },
})

h.nmap("<leader>aa", function() harpoon_mark.add_file() end, { desc = "Add a file to harpoon" })
h.nmap("<leader>an", function() harpoon_ui.nav_next() end, { desc = "Go to the next harpoon item" })
h.nmap("<leader>ap", function() harpoon_ui.nav_prev() end, { desc = "Go to the previous harpoon item" })
h.nmap("<leader>at", function() harpoon_ui.toggle_quick_menu() end, { desc = "Toggle the harpoon menu" })

vim.api.nvim_set_hl(0, "HarpoonBorder", { fg = colors.orange })
