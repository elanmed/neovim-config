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

vim.api.nvim_create_autocmd("CursorMoved", {
  pattern = "*",
  callback = function()
    local winnr = vim.api.nvim_get_current_win()
    local num_screen_lines = vim.api.nvim_win_get_height(winnr)
    local num_half_screen_lines = math.floor(num_screen_lines / 2)

    local num_file_lines = vim.fn.line "$"
    local curr_line = vim.fn.line "."

    if curr_line >= (num_file_lines - num_half_screen_lines) then
      h.keys.send_keys("n", "zz")
    end
  end,
})

-- cinnamon remaps <C-f>, so remap it manually after calling cinnamon.setup
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
