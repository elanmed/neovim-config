local ok, configs = pcall(require, "nvim-treesitter.configs")
if not ok then
  return
end

configs.setup({
  ensure_installed = { "bash", "comment", "css", "html", "javascript", "json", "json5", "jsonc", "lua", "markdown",
    "regex", "ruby", "scss", "tsx", "typescript", "yaml", },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false, -- prevent vim highlight from interfering with treesitter
  },
  indent = { enable = true },
  rainbow = {
    enable = true,
    extended_mode = false,
  },
  autotag = {
    enable = true,
  },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
})
