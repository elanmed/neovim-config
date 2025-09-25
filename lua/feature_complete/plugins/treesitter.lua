require "nvim-treesitter.configs".setup {
  auto_install = true,
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

vim.filetype.add { extension = { mdx = "mdx", }, }
vim.treesitter.language.register("markdown", "mdx")

require "ts_context_commentstring".setup {}
require "nvim-ts-autotag".setup {}
local gen_spec = require "mini.ai".gen_spec
require "mini.ai".setup {
  custom_textobjects = {
    F = gen_spec.treesitter { a = "@function.outer", i = "@function.inner", },
  },
}
