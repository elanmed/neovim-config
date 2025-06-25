local colorful_menu = require "colorful-menu"
colorful_menu.setup {}

local blink = require "blink.cmp"
blink.setup {
  keymap = {
    preset = "none",
    ["<C-x>"] = { "show", },
    ["<Cr>"] = { "accept", "fallback", },
    ["<C-y>"] = { "accept", },
    ["<C-c>"] = { "cancel", },
    ["<C-n>"] = { "select_next", "fallback", },
    ["<C-p>"] = { "select_prev", "fallback", },
    ["<Down>"] = { "select_next", "fallback", },
    ["<Up>"] = { "select_prev", "fallback", },
    ["<C-d>"] = { "scroll_documentation_down", },
    ["<C-u>"] = { "scroll_documentation_up", },
  },
  completion = {
    documentation = { auto_show = true, window = { border = "single", }, },
    list = { selection = { auto_insert = false, }, },
    menu = {
      draw = {
        -- https://github.com/xzbdmw/colorful-menu.nvim#use-it-in-blinkcmp
        columns = { { "kind_icon", }, { "label", gap = 1, }, },
        components = {
          label = {
            text = function(ctx)
              return colorful_menu.blink_components_text(ctx)
            end,
            highlight = function(ctx)
              return colorful_menu.blink_components_highlight(ctx)
            end,
          },
        },
      },
    },
  },
  sources = {
    default = { "lsp", "path", "buffer", },
  },
  signature = {
    enabled = true,
    window = { show_documentation = false, border = "single", },
  },
  -- fuzzy = { prebuilt_binaries = { force_version = "v1.3.1", }, },
  fuzzy = { implementation = "lua", },
}

require "nvim-autopairs".setup {}
