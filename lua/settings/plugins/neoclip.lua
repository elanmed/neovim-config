package.path = package.path .. ";../?.lua"
local h = require("settings.helpers")

local ok, neoclip = pcall(require, "neoclip")
if not ok then
  return
end

-- TODO: figure out remaps
neoclip.setup({
  keys = {
    telescope = {
      i = {
        --[[ select = '<cr>', ]]
        --[[ paste = '<c-p>', ]]
        --[[ paste_behind = '<c-k>', ]]
        --[[ delete = '<c-d>', -- delete an entry ]]
        --[[ custom = {}, ]]
      },
      n = {
        --[[ select = '<cr>', ]]
        --[[ paste = 'p', ]]
        --[[ paste_behind = 'P', ]]
        --[[ delete = 'd', ]]
        --[[ custom = {}, ]]
      },
    },
  }

})
h.nmap("<leader>y",
  "<cmd>lua require('telescope').extensions.neoclip.default(require('telescope.themes').get_ivy({}))<cr>")
h.vmap("<leader>y",
  "<cmd>lua require('telescope').extensions.neoclip.default(require('telescope.themes').get_ivy({}))<cr>")
