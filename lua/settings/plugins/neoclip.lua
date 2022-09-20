package.path = package.path .. ";../?.lua"
local h = require("settings.helpers")

local ok, neoclip = pcall(require, "neoclip")
if not ok then
  return
end

-- https://github.com/AckslD/nvim-neoclip.lua#configuration
neoclip.setup()
h.nmap("<leader>y",
  "<cmd>lua require('telescope').extensions.neoclip.default(require('telescope.themes').get_ivy({}))<cr>")
h.vmap("<leader>y",
  "<cmd>lua require('telescope').extensions.neoclip.default(require('telescope.themes').get_ivy({}))<cr>")
