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
  indent = { enable = true, },
  endwise = { enable = true, },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      -- TODO: use these more
      keymaps = {
        ["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment", },
        ["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment", },
        ["l="] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment", },
        ["r="] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment", },

        ["a:"] = { query = "@property.outer", desc = "Select outer part of an object property", },
        ["i:"] = { query = "@property.inner", desc = "Select inner part of an object property", },
        ["l:"] = { query = "@property.lhs", desc = "Select left part of an object property", },
        ["r:"] = { query = "@property.rhs", desc = "Select right part of an object property", },

        ["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional", },
        ["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional", },

        ["af"] = { query = "@function.outer", desc = "Select outer part of a method/function definition", },
        ["if"] = { query = "@function.inner", desc = "Select inner part of a method/function definition", },
      },
    },
  },
}

require "ibl".setup {
  scope = {
    show_start = false,
    show_end = false,
  },
}

--require "render-markdown".setup {
  -- https://github.com/MeanderingProgrammer/render-markdown.nvim/wiki#render-modes
 -- render_modes = true,
--}

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
h.keys.map({ "n", }, "<C-b>", h.keys.user_cmd_cb "AerialToggle left", { desc = "Toggle aerial window", })

vim.api.nvim_set_hl(0, "AerialLine", { link = "Visual", })

h.let.skip_ts_context_commentstring_module = true

require "ts_context_commentstring".setup {
  enable_autocmd = false,
}
require "Comment".setup {
  pre_hook = require "ts_context_commentstring.integrations.comment_nvim".create_pre_hook(),
  toggler = {
    line = "<leader>cc",
    block = "<leader>bb",
  },
  -- multiple lines
  opleader = {
    line = "<leader>mc",
    block = "<leader>mb",
  },
  mappings = {
    basic = true,
    extra = false,
    extended = false,
  },
}
require "Comment.ft".lua = { "-- %s", "-- %s", }
require "nvim-ts-autotag".setup {}
