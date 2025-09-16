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
end, { desc = "Toggle mini files", })

-- https://github.com/folke/snacks.nvim/blob/main/docs/rename.md#minifiles
vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesActionRename",
  callback = function(event)
    snacks.rename.on_rename_file(event.data.from, event.data.to)
  end,
})
