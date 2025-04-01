local h = require "shared.helpers"
local snacks = require "snacks"

h.keys.map({ "n", }, "<C-f>", h.keys.vim_cmd_cb "Oil", { desc = "Toggle oil", })
h.keys.map({ "n", }, "<leader>ne", snacks.explorer.reveal, { desc = "Open snacks explorer", })

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
