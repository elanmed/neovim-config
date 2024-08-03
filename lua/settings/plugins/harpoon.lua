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

h.nmap("<leader>ha", function() harpoon_mark.add_file() end, { desc = "Add a file to harpoon" })
h.nmap("<leader>he", function() harpoon_ui.nav_next() end, { desc = "Go to the next harpoon item" })
h.nmap("<leader>hr", function() harpoon_ui.nav_prev() end, { desc = "Go to the previous harpoon item" })
h.nmap("<leader>ht", function() harpoon_ui.toggle_quick_menu() end, { desc = "Open the harpoon menu" })

vim.api.nvim_set_hl(0, "HarpoonBorder", { fg = colors.orange })
