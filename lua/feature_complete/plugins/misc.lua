local h = require "shared.helpers"

--- @type snacks.Config
require "snacks".setup {
  indent = { enabled = true, animate = { enabled = false, }, },
  explorer = { enabled = true, replace_netrw = false, },
}

h.keys.map("n", "<leader>tm", function()
  vim.cmd "UndotreeToggle"
  vim.cmd "wincmd h"
end, { desc = "Toggle undotree", })

vim.api.nvim_create_autocmd({ "BufEnter", }, {
  pattern = "*",
  callback = function()
    if h.tbl.contains_value({ "aerial", "undotree", }, vim.bo.filetype) then
      h.set.cursorline = true
    else
      h.set.cursorline = false
    end
  end,
})
