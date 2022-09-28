package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/nvim/?.lua"
local h = require("shared.helpers")

h.nmap("<leader>rb", ":Lexplore<cr>")
