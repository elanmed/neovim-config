local h = require "shared.helpers"

h.keys.map({ "n", }, "<C-f>", h.keys.user_cmd_cb "Oil", { desc = "Toggle oil", })
h.keys.map({ "n", }, "<leader>ne", h.keys.user_cmd_cb "NERDTreeFind", { desc = "Open NERDTree", })

vim.api.nvim_set_var("NERDTreeWinSize", 100)

require "oil".setup {
  default_file_explorer = true,
  delete_to_trash = true,
  view_options = {
    show_hidden = true,
  },
  use_default_keymaps = false,
  keymaps = {
    ["g?"] = "actions.show_help",
    ["<cr>"] = "actions.select",
    ["<C-f>"] = "actions.close",
    ["-"] = "actions.parent",
    ["g."] = "actions.toggle_hidden",
  },
}
