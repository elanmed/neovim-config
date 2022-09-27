package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/nvim/?.lua"
local h = require("shared.helpers")

local ok, harpoon = pcall(require, "harpoon")
if not ok then
  return
end
harpoon.setup({})

h.nmap("<leader>aa", [[<cmd>lua require("harpoon.mark").add_file()<cr>]])
h.nmap("<leader>at", [[<cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>]])
h.nmap("<leader>an", [[<cmd>lua require("harpoon.ui").nav_next()<cr>]])
h.nmap("<leader>ap", [[<cmd>lua require("harpoon.ui").nav_prev()<cr>]])
h.nmap("<leader>aj", [[<cmd>lua require("harpoon.ui").nav_file(1)<cr>]])
h.nmap("<leader>ak", [[<cmd>lua require("harpoon.ui").nav_file(2)<cr>]])
