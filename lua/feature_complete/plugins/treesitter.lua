local h = require "shared.helpers"

require "nvim-treesitter.configs".setup {
  ensure_installed = {
    "bash",
    "comment",
    "css",
    "html",
    "javascript",
    "json",
    "json5",
    "jsonc",
    "lua",
    "vim",
    "markdown",
    "markdown_inline",
    "regex",
    "ruby",
    "scss",
    "tsx",
    "typescript",
    "yaml",
    "vimdoc",
    "luadoc",
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  endwise = { enable = true, },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional", },
        ["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional", },

        ["af"] = { query = "@function.outer", desc = "Select outer part of a method/function definition", },
        ["if"] = { query = "@function.inner", desc = "Select inner part of a method/function definition", },
      },
    },
  },
}

require "render-markdown".setup {
  -- https://github.com/MeanderingProgrammer/render-markdown.nvim/wiki#render-modes
  render_modes = true,
}

require "aerial".setup {
  lazy_load = false,
  show_guides = true,
  layout = {
    resize_to_content = true,
    max_width = 0.4,
    width = nil,
    min_width = nil,
  },
  keymaps = {
    ["<C-b>"] = "actions.close",
  },
}
h.keys.map({ "n", }, "<C-b>", h.keys.vim_cmd_cb "AerialToggle left", { desc = "Toggle aerial window", })

require "ts_context_commentstring".setup {}
require "nvim-ts-autotag".setup {}

h.keys.map({ "i", }, "<C-_>", "<C-o><Plug>ContextCommentaryLine")
h.keys.map({ "n", }, "<C-_>", "<Plug>ContextCommentaryLine")
h.keys.map({ "v", }, "<C-_>", "<Plug>ContextCommentarygv")
