local h = require "shared.helpers"
local snacks = require "snacks"

require "cinnamon".setup {
  keymaps = {
    basic = true,
  },
  options = {
    mode = "window",
  },
}

-- cinnamon remaps *
vim.keymap.set("n", "*", function()
  -- https://superuser.com/a/299693
  local word = vim.fn.expand "<cword>"
  vim.cmd([[let @/ = '\<]] .. word .. [[\>']])
  vim.api.nvim_set_option_value("hlsearch", true, {})
end, { silent = true, desc = "*, but stay on the current search result", })

-- cinnamon remaps <C-f>
vim.keymap.set("n", "<C-f>", h.keys.vim_cmd_cb "Oil", { desc = "Toggle oil", })
vim.keymap.set("n", "<leader>ti", snacks.explorer.reveal, { desc = "Open snacks explorer", })

require "oil".setup {
  default_file_explorer = true,
  delete_to_trash = true,
  view_options = {
    show_hidden = true,
  },
  use_default_keymaps = false,
  keymaps = {
    ["?"] = "actions.show_help",
    ["<cr>"] = "actions.select",
    ["<C-f>"] = "actions.close",
    ["-"] = "actions.parent",
    ["g."] = "actions.toggle_hidden",
  },
}
-- https://github.com/folke/snacks.nvim/blob/main/docs/rename.md#oilnvim
vim.api.nvim_create_autocmd("User", {
  pattern = "OilActionsPost",
  callback = function(event)
    if event.data.actions.type == "move" then
      snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
    end
  end,
})
