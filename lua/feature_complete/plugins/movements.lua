local h = require "shared.helpers"
local flash = require "flash"
local marks = require "marks"
local colors = require "feature_complete.plugins.colorscheme"
local cinnamon = require "cinnamon"

cinnamon.setup {
  options = {
    mode = "window",
  },
}

--- @param movement string
local function cinnamon_scroll_cb(movement)
  return function() cinnamon.scroll(movement) end
end

vim.keymap.set({ "n", "v", "i", }, "<C-u>", function()
  if vim.fn.line "." == vim.fn.line "$" then
    cinnamon.scroll "M"
  else
    cinnamon.scroll "<C-u>"
  end
end)
vim.keymap.set({ "n", "v", "i", }, "<C-d>", function()
  if vim.fn.line "." == 1 then
    cinnamon.scroll "M"
  else
    cinnamon.scroll "<C-d>"
  end
end)
vim.keymap.set("n", "n", cinnamon_scroll_cb "n")
vim.keymap.set("n", "N", cinnamon_scroll_cb "N")
vim.keymap.set("n", "}", cinnamon_scroll_cb "}")
vim.keymap.set("n", "{", cinnamon_scroll_cb "{")

require "multicursors".setup {
  hint_config = false,
}
vim.keymap.set("n", "<leader>tm", function()
  vim.cmd "MCstart"
  h.notify.doing "Starting multicursor"
end)

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
vim.keymap.set("n", "<leader>v", function() flash.treesitter() end)
vim.keymap.set("n", "<leader>s", function()
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
--- @param mark string
local function is_global_mark_unset(mark)
  local maybe_mark = vim.api.nvim_get_mark(mark, {})
  return maybe_mark[1] == 0 and maybe_mark[2] == 0 and maybe_mark[3] == 0 and maybe_mark[4] == ""
end

--- @param mark string
local function is_buffer_mark_unset(mark)
  local maybe_mark = vim.api.nvim_buf_get_mark(h.curr.buffer, mark)
  return maybe_mark[1] == 0 and maybe_mark[2] == 0
end

local global_marks = ("abcdefghijklmnopqrstuvwxyz"):upper()

vim.keymap.set("n", "mg", function()
  for letter in global_marks:gmatch "." do
    local is_buffer_mark_set = not is_buffer_mark_unset(letter)

    if is_buffer_mark_set then
      h.notify.warn("Mark " .. letter .. " is already set for this buffer!")
      return
    end
  end

  local next_avail_mark = nil
  for letter in global_marks:gmatch "." do
    if is_global_mark_unset(letter) then
      next_avail_mark = letter
      break
    end
  end

  if next_avail_mark == nil then
    h.notify.error "No upper case marks available!"
    return
  end

  local line_one_indexed = 1
  local col_zero_indexed = 0
  vim.api.nvim_buf_set_mark(h.curr.buffer, next_avail_mark, line_one_indexed, col_zero_indexed, {})
  h.notify.doing("Set mark " .. next_avail_mark)
end, { desc = "Set a global mark for the buffer", })

vim.keymap.set("n", "dmg", function()
  for letter in global_marks:gmatch "." do
    local is_buffer_mark_set = not is_buffer_mark_unset(letter)

    if is_buffer_mark_set then
      vim.api.nvim_del_mark(letter)
      h.notify.doing("Deleted mark " .. letter)
      return
    end
  end
  h.notify.warn "No global mark in the buffer"
end, { desc = "Delete a global mark for the buffer", })

vim.keymap.set("n", "dma", h.keys.vim_cmd_cb "delmarks A-Z", { desc = "Delete all marks", })
