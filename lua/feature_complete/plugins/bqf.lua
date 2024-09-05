local h = require "shared.helpers"

-- TODO: figure out a way to clear only one list, not all
-- delete all quickfix lists
h.nmap("gc", h.user_cmd_cb("cex \"\""), { desc = "Clear all quickfix lists" })

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = "*",
  callback = function()
    if h.table_contains({ "qf", "DiffviewFiles", "aerial" }, vim.bo.filetype) then
      h.set.cursorline = true
      vim.api.nvim_set_hl(0, "CursorLine", { link = "Visual" })
    else
      h.set.cursorline = false
    end
  end
})

return {
  "kevinhwang91/nvim-bqf",
  commit = "1b24dc6",
  opts = {
    auto_resize_height = true,
    func_map = {
      openc = "<cr>",
    },
    preview = {
      winblend = 0
    }
  },
  dependencies = {
    { "junegunn/fzf", build = "./install --bin", commit = "a09c6e9" },
  }
}
