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
    "fennel",
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  endwise = { enable = true, },
}

require "ts_context_commentstring".setup {}
require "nvim-ts-autotag".setup {}
require "mini.ai".setup()
