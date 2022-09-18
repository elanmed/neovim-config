package.path = package.path .. ";../?.lua"
local h = require("settings.helpers")

local ok, telescope = pcall(require, "telescope")
if not ok then
  return
end

telescope.setup({
  defaults = {
    -- TODO: figure out these remappings
    mappings = {
      n = {
        ["<C-h>"] = "send_selected_to_qflist"
      },
      i = {
        ["<C-h>"] = "send_selected_to_qflist"
      }
    }
  },
  pickers = {
    live_grep = {
      theme = "ivy",
    },
    grep_string = {
      theme = "ivy",
    },
    resume = {
      theme = "ivy",
    },
  },
  --[[ extensions = { ]]
  --[[   frecency = { ]]
  --[[     theme = "ivy" ]]
  --[[   } ]]
  --[[ } ]]
})
telescope.load_extension('fzf')
telescope.load_extension("frecency") -- loads results based on frequency

-- TODO: figure out ivy theme in setup
h.nmap('<C-p>',
  [[<cmd>lua require('telescope').extensions.frecency.frecency(require('telescope.themes').get_ivy({}))<cr>]])
h.nmap("<leader>zf", [[<cmd>lua require('telescope.builtin').grep_string({ search = vim.fn.input("Grep For > ")})<cr>]])
h.nmap("<leader>zu", [[<cmd>lua require('telescope.builtin').resume()<cr>]])

h.nmap("<leader>zo", [[<cmd>lua require('telescope.builtin').grep_string()<cr>]]) -- grep over current word
-- TODO: convert over to lua functions
h.vmap("<leader>zo", [["zy<cmd>exec 'Telescope grep_string search=' . escape(@z, ' ')<cr>]])
