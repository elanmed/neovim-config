package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/nvim/?.lua"
local h = require("shared.helpers")

local ok, neoclip = pcall(require, "neoclip")
if not ok then
  return
end

neoclip.setup()
h.nmap("<leader>y", "<cmd>lua require('telescope').extensions.neoclip.default()<cr>")
h.vmap("<leader>y", "<cmd>lua require('telescope').extensions.neoclip.default()<cr>")
