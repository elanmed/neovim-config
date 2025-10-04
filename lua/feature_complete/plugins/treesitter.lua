require "nvim-treesitter.configs".setup {
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<leader>v",
      node_incremental = "an",
      scope_incremental = "an",
      node_decremental = "in",
    },
  },
}

vim.filetype.add { extension = { mdx = "mdx", }, }
vim.treesitter.language.register("markdown", "mdx")

require "nvim-ts-autotag".setup {}
local gen_spec = require "mini.ai".gen_spec
require "mini.ai".setup {
  custom_textobjects = {
    F = gen_spec.treesitter { a = "@function.outer", i = "@function.inner", },
  },
}
