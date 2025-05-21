local blink = require "blink.cmp"
blink.setup {
  keymap = {
    preset = "none",
    ["<C-x>"] = { "show", },
    ["<C-y>"] = { "accept", },
    ["<C-c>"] = { "cancel", },
    ["<C-n>"] = { "select_next", "fallback", },
    ["<C-p>"] = { "select_prev", "fallback", },
    ["<C-d>"] = { "scroll_documentation_down", },
    ["<C-u>"] = { "scroll_documentation_up", },
  },
  completion = {
    documentation = { auto_show = true, window = { border = "single", }, },
    ghost_text = { enabled = true, },
    list = { selection = { auto_insert = false, }, },
  },
  sources = {
    default = { "lsp", "path", "buffer", },
  },
  fuzzy = { prebuilt_binaries = { force_version = "v1.3.1", }, },
}

require "nvim-autopairs".setup {}
