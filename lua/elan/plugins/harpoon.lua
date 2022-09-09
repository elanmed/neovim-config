package.path = package.path .. ";../?.lua"
local h = require("elan.helpers")

require("harpoon").setup({})

h.nmap("<leader>aa", [[:lua require("harpoon.mark").add_file()<cr>]])
h.nmap("<leader>at", [[:lua require("harpoon.ui").toggle_quick_menu()<cr>]])
h.nmap("<leader>an", [[:lua require("harpoon.ui").nav_next()<cr>]])
h.nmap("<leader>ap", [[:lua require("harpoon.ui").nav_prev()<cr>]])
h.nmap("<leader>aj", [[:lua require("harpoon.ui").nav_file(1)<cr>]])
h.nmap("<leader>ak", [[:lua require("harpoon.ui").nav_file(2)<cr>]])
