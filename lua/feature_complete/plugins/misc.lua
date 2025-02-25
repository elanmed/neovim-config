local h = require "shared.helpers"

--- @type snacks.Config
require "snacks".setup {
  indent = { enabled = true, animate = { enabled = false, }, },
  explorer = { enabled = true, replace_netrw = false, },
}

h.keys.map({ "n", }, "<leader>me", function()
  vim.cmd "UndotreeToggle"
  vim.cmd "wincmd h"
end, { desc = "Toggle undotree", })
