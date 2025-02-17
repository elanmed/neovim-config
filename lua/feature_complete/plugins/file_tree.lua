local h = require "shared.helpers"

h.keys.map({ "n", }, "<C-f>", h.keys.user_cmd_cb "Oil", { desc = "Toggle oil", })
h.keys.map({ "n", }, "<leader>ne", h.keys.user_cmd_cb "NERDTreeFind", { desc = "Open NERDTree", })
h.let.NERDTreeWinSize = 100

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

h.keys.map({ "n", }, "<leader>me", h.keys.user_cmd_cb "UndotreeToggle", { desc = "Toggle undotree", })

-- https://github.com/folke/snacks.nvim/blob/main/docs/rename.md#oilnvim
vim.api.nvim_create_autocmd("User", {
  pattern = "OilActionsPost",
  callback = function(event)
    if event.data.actions.type == "move" then
      Snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
    end
  end,
})
