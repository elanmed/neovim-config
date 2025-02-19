local h = require "shared.helpers"

--- @type snacks.Config
require "snacks".setup {
  image = { enabled = true, },
  indent = { enabled = true, animate = { enabled = false, }, },
  explorer = { enabled = true, replace_netrw = false, },
}

h.keys.map({ "n", }, "<leader>me", function()
  vim.cmd "UndotreeToggle"
  vim.cmd "wincmd h"
end, { desc = "Toggle undotree", })
