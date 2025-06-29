require "nvim-treesitter.configs".setup {
  ensure_installed = {
    "bash",
    "comment",
    "css",
    "editorconfig",
    "git_config",
    "gitignore",
    "html",
    "java",
    "javascript",
    "json",
    "json5",
    "jsonc",
    "lua",
    "markdown",
    "markdown_inline",
    "regex",
    "ruby",
    "scss",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "yaml",
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

require "ts_context_commentstring".setup {}
require "nvim-ts-autotag".setup {}
