local h = require "shared.helpers"

local base16 = require "base16-colorscheme"
local colors = {
  base00 = '#1d1f21',
  base01 = '#282a2e',
  base02 = '#373b41',
  base03 = '#969896',
  base04 = '#b4b7b4',
  base05 = '#c5c8c6',
  base06 = '#e0e0e0',
  base07 = '#ffffff',
  base08 = '#cc6666',
  base09 = '#de935f', -- cursor
  base0A = '#f0c674',
  base0B = '#b5bd68',
  base0C = '#8abeb7',
  base0D = '#81a2be',
  base0E = '#b294bb',
  base0F = '#a3685a'
}
base16.setup(colors)

local function is_quickfix()
  return vim.fn.getbufvar(vim.fn.bufnr('%'), '&buftype') == 'quickfix'
end


vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "*",
  callback = function(e)
    h.dump(e)
    if is_quickfix() then
      h.set.cursorline = true
    else
      h.set.cursorline = false
    end
  end
})


local bufferline = require "bufferline"
bufferline.setup({
  options = {
    diagnostics = "coc",
    style_preset = bufferline.style_preset.no_italic,
    close_command = "Bdelete",
    right_mouse_command = nil,
    left_mouse_command = nil,
    indicator = {
      style = 'underline'
    },
  }
})

vim.api.nvim_set_hl(0, "BufferLineBufferSelected", { fg = colors.base0C, underline = true })
vim.api.nvim_set_hl(0, "CursorLine", { fg = colors.base09, bg = colors.base02, underline = true })

h.nmap("<leader>tp", h.user_cmd_cb("BufferLinePick"))
h.nmap("<leader>ti", h.user_cmd_cb("BufferLineTogglePin"))
h.nmap("<leader>tl", h.user_cmd_cb("BufferLineMoveNext"))
h.nmap("<leader>th", h.user_cmd_cb("BufferLineMovePrev"))
h.nmap("L", h.user_cmd_cb("BufferLineCycleNext"))
h.nmap("H", h.user_cmd_cb("BufferLineCyclePrev"))

h.nmap("<leader>tw", h.user_cmd_cb("Bdelete"))
h.nmap("<leader>ta", h.user_cmd_cb("bufdo Bdelete"))
h.nmap("<leader>to", h.user_cmd_cb("BufOnly"))
