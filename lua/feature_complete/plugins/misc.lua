local h = require "shared.helpers"

--- @type snacks.Config
require "snacks".setup {
  image = { enabled = true, },
  indent = { enabled = true, animate = { enabled = false, }, },
  explorer = { enabled = true, replace_netrw = false, },
}

h.keys.map({ "n", }, "<leader>me", h.keys.user_cmd_cb "UndotreeToggle", { desc = "Toggle undotree", })
