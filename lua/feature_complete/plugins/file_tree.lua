local h = require "helpers"
local snacks = require "snacks"

vim.keymap.set("n", "<C-f>", h.keys.vim_cmd_cb "Oil", { desc = "Toggle oil", })
vim.keymap.set("n", "-", h.keys.vim_cmd_cb "Oil", { desc = "Toggle oil", })
vim.keymap.set("n", "<leader>ti", snacks.explorer.reveal, { desc = "Open snacks explorer", })

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
    ["-"] = "actions.parent",
    ["<c-i>"] = "actions.select",
    ["<c-o>"] = "actions.parent",
    ["<C-f>"] = "actions.close",
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
