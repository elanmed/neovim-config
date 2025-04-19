local h = require "shared.helpers"
local flash = require "flash"
local marks = require "marks"
local colors = require "feature_complete.plugins.colorscheme"

require "custom_plugins.ft_preview".setup()

vim.api.nvim_set_hl(h.curr.namespace, "FTPreviewSecond",
  { fg = colors.yellow, bg = colors.black, underline = true, bold = true, })
vim.api.nvim_set_hl(h.curr.namespace, "FTPreviewThird",
  { fg = colors.red, bg = colors.black, underline = true, bold = true, })
vim.api.nvim_set_hl(h.curr.namespace, "FTPreviewDimmed", { fg = colors.light_grey, bg = colors.black, })

flash.setup {
  modes = {
    char = {
      enabled = false,
    },
  },
  prompt = {
    prefix = { { "󱐋 ", "FlashPromptIcon", }, },
  },
}

vim.keymap.set("n", "s", function() flash.jump { forward = true, } end)
vim.keymap.set("n", "S", function() flash.jump { forward = false, } end)
vim.keymap.set("n", "<leader>sa", function()
  -- https://github.com/folke/flash.nvim#-examples
  flash.jump {
    forward = true,
    search = {
      mode = "search",
      max_length = 0,
    },
    label = {
      after = { 0, 0, },
    },
    pattern = "^",
  }
end)

marks.setup {
  excluded_filetypes = { "oil", },
  default_mappings = false,
  mappings = {
    toggle = "mt",
    next = "me", -- nExt
    prev = "mr", -- pRev
    delete_line = "dml",
    delete_buf = "dmb",
  },
}
vim.keymap.set("n", "mgg", function()
  local view = vim.fn.winsaveview()
  vim.cmd "1"
  marks.set_next()
  vim.fn.winrestview(view)
  h.notify.info "mark set!"
end, { desc = "Set a mark at the top of the file", })

vim.keymap.set("n", "dma", h.keys.vim_cmd_cb "delmarks A-Za-z0-9", { desc = "Delete all marks", })
