require "nvim-autopairs".setup {}

local colorful_menu = require "colorful-menu"
colorful_menu.setup {}

local blink = require "blink.cmp"
local blink_types = require "blink.cmp.types"

vim.keymap.set("i", "<C-n>", "<nop>")
blink.setup {
  keymap = {
    preset = "none",
    ["<C-n>"] = { "show", "select_next", },
    ["<Cr>"] = { "accept", "fallback", },
    ["<C-y>"] = { "accept", "fallback", },
    ["<C-c>"] = { "cancel", "fallback", },
    ["<C-p>"] = { "select_prev", "fallback", },
    ["<Down>"] = { "select_next", "fallback", },
    ["<Up>"] = { "select_prev", "fallback", },
    ["<C-d>"] = { "scroll_documentation_down", "fallback", },
    ["<C-u>"] = { "scroll_documentation_up", "fallback", },
  },
  completion = {
    documentation = { window = { border = "rounded", }, auto_show = true, auto_show_delay_ms = 0, },
    list = { selection = { preselect = false, auto_insert = true, }, },
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
  cmdline = { sources = { enabled = false, }, },
  sources = {
    default = { "buffer", "lsp", "path", },
    -- https://cmp.saghen.dev/configuration/snippets.html#disable-all-snippets
    transform_items = function(_, items)
      return vim.tbl_filter(function(item)
        return item.kind ~= blink_types.CompletionItemKind.Snippet
      end, items)
    end,
    providers = {
      -- https://cmp.saghen.dev/recipes.html#exclude-keywords-constants-from-autocomplete
      lsp = {
        name = "LSP",
        module = "blink.cmp.sources.lsp",
        transform_items = function(_, items)
          return vim.tbl_filter(function(item)
            return item.kind ~= blink_types.CompletionItemKind.Keyword
          end, items)
        end,
      },
      -- https://cmp.saghen.dev/recipes.html#buffer-completion-from-all-open-buffers
      buffer = {
        opts = {
          get_bufnrs = function()
            return vim.tbl_filter(function(bufnr)
              -- :h buftype
              return vim.bo[bufnr].buftype == ""
            end, vim.api.nvim_list_bufs())
          end,
        },
      },
    },
  },
  signature = {
    enabled = true,
    window = { show_documentation = false, border = "rounded", },
  },
  -- fuzzy = { prebuilt_binaries = { force_version = "v1.3.1", }, },
  fuzzy = { implementation = "lua", },
}
