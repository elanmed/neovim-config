local h = require "shared.helpers"
local bqf = require "bqf"

bqf.setup {
  auto_resize_height = true,
  func_map = {
    openc = "<cr>",
    open = "o",
  },
  preview = {
    winblend = 0,
    -- https://github.com/kevinhwang91/nvim-bqf?tab=readme-ov-file#customize-configuration
    should_preview_cb = function(bufnr)
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      local fsize = vim.fn.getfsize(bufname)
      -- file size greater than 100k
      if fsize > 100 * 1024 then
        return false
      end
      return true
    end,
  },
}

-- TODO: figure out a way to clear only one list, not all
-- delete all quickfix lists
h.map({ "n", }, "gc", h.user_cmd_cb "cex \"\"", { desc = "Clear all quickfix lists", })

-- require "bqf.qfwin.handler".open(true, "vsplit")
-- require "bqf.qfwin.handler".navFile(true)
-- require "bqf.qfwin.handler".open(false)

vim.api.nvim_create_autocmd({ "BufEnter", }, {
  pattern = "*",
  callback = function()
    if h.table_contains_value({ "qf", "DiffviewFiles", "aerial", }, vim.bo.filetype) then
      h.set.cursorline = true
      vim.api.nvim_set_hl(0, "CursorLine", { link = "Visual", })
    else
      h.set.cursorline = false
    end
  end,
})
