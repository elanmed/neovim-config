local h = require "shared.helpers"

h.keys.map({ "n", }, "<C-f>", h.keys.user_cmd_cb "Oil", { desc = "Toggle oil", })
h.keys.map({ "n", }, "<leader>ne", h.keys.user_cmd_cb "Lexplore %:p:h", { desc = "Open netrw as a tree to the side", })
h.let.netrw_winsize = 50

require "oil".setup {
  default_file_explorer = false,
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
