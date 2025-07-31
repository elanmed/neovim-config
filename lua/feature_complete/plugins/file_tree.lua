local snacks = require "snacks"

local mini_files = require "mini.files"
mini_files.setup {
  mappings = {
    close = "<esc>",
    go_in = "l",
    go_in_plus = "<cr>",
    go_out = "h",
    go_out_plus = "",
    mark_goto = "",
    mark_set = "",
    reset = "q",
    reveal_cwd = "",
    synchronize = "<bs>",
  },
  options = {
    permanent_delete = false,
  },
}

vim.keymap.set("n", "<C-f>", function()
  if not mini_files.close() then
    mini_files.open(vim.api.nvim_buf_get_name(0))
  end
end, { desc = "Toggle oil", })
vim.keymap.set("n", "<leader>t", snacks.explorer.reveal, { desc = "Open snacks explorer", })

-- require "oil".setup {
--   default_file_explorer = true,
--   delete_to_trash = true,
--   view_options = {
--     show_hidden = true,
--   },
--   use_default_keymaps = false,
--   keymaps = {
--     ["g?"] = "actions.show_help",
--     ["<cr>"] = "actions.select",
--     ["-"] = "actions.parent",
--     ["<c-i>"] = "actions.select",
--     ["<c-o>"] = "actions.parent",
--     ["<C-f>"] = "actions.close",
--     ["g."] = "actions.toggle_hidden",
--   },
-- }
--
-- -- https://github.com/folke/snacks.nvim/blob/main/docs/rename.md#oilnvim
-- vim.api.nvim_create_autocmd("User", {
--   pattern = "OilActionsPost",
--   callback = function(event)
--     if event.data.actions.type == "move" then
--       snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
--     end
--   end,
-- })

-- https://github.com/folke/snacks.nvim/blob/main/docs/rename.md#minifiles
vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesActionRename",
  callback = function(event)
    snacks.rename.on_rename_file(event.data.from, event.data.to)
  end,
})
