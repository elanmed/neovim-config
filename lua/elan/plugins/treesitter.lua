local configs = require("nvim-treesitter.configs")

configs.setup({
  ensure_installed = "all",
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false, -- prevent vim highlight from interfering with treesitter
  },
  indent = { enable = true },
  rainbow = {
    enable = true,
    extended_mode = true, -- also highlight non-bracket delimiters like html tags, boolean or table
    max_file_lines = nil, -- do not enable for files with more than n lines, int
  },
  autotag = {
    enable = true,
  },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
})
