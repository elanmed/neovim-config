local h = require "shared.helpers"

require("nvim-treesitter.configs").setup({
  {
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
      "regex",
      "ruby",
      "scss",
      "tsx",
      "typescript",
      "yaml",
      "vimdoc",
      "luadoc"
    },
    indent = { enable = true },
    autotag = { enable = true, },
    endwise = { enable = true, },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
        ["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
        ["l="] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment" },
        ["r="] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment" },

        ["a:"] = { query = "@property.outer", desc = "Select outer part of an object property" },
        ["i:"] = { query = "@property.inner", desc = "Select inner part of an object property" },
        ["l:"] = { query = "@property.lhs", desc = "Select left part of an object property" },
        ["r:"] = { query = "@property.rhs", desc = "Select right part of an object property" },

        ["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
        ["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },

        ["af"] = { query = "@function.outer", desc = "Select outer part of a method/function definition" },
        ["if"] = { query = "@function.inner", desc = "Select inner part of a method/function definition" },
      },
    },
  },
})


require("ibl").setup({
  scope = {
    show_start = false,
    show_end = false
  }
})

require("render-markdown").setup({})

require("aerial").setup({
  lazy_load = false,
  show_guides = true,
  -- use automatic resizing
  layout = {
    resize_to_content = true,
    max_width = 0.4,
    width = nil,
    min_width = nil,
  },
  keymaps = {
    ["<C-g>"] = "actions.close",
  }
})

h.let.skip_ts_context_commentstring_module = true

require("ts_context_commentstring").setup({
  enable_autocmd = false
})
require("Comment").setup({
  pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
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
})
require("Comment.ft").lua = { "-- %s", "-- %s" }

h.nmap("zn", h.user_cmd_cb("AerialNext"), { desc = "Go to the next aerial symbol" })
h.nmap("zp", h.user_cmd_cb("AerialPrev"), { desc = "Go to the prev aerial symbol" })
h.nmap("<C-g>", h.user_cmd_cb("AerialToggle left"), { desc = "Toggle aerial  window" })

vim.api.nvim_set_hl(0, "AerialLine", { link = "Visual" })
