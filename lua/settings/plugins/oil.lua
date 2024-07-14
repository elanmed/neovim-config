local h = require "shared.helpers"
local oil = require "oil"

oil.setup({
  default_file_explorer = true,
  delete_to_trash = true,
  view_options = {
    show_hidden = true
  },
  use_default_keymaps = false,
  keymaps = {
    ["g?"] = "actions.show_help",
    ["<cr>"] = "actions.select",
    ["<leader>r"] = "actions.close",
    ["-"] = "actions.parent",
    ["g."] = "actions.toggle_hidden",
  },
})
h.nmap("<leader>r", h.user_cmd_cb("Oil"), { desc = "Toggle oil" })
