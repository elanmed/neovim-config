require "conform".setup {
  formatters_by_ft = {
    css = { "prettier", },
    graphql = { "prettier", },
    html = { "prettier", },
    javascript = { "prettier", },
    javascriptreact = { "prettier", },
    json = { "prettier", },
    less = { "prettier", },
    markdown = { "prettier", },
    scss = { "prettier", },
    typescript = { "prettier", },
    typescriptreact = { "prettier", },
    yaml = { "prettier", },
  },
  format_after_save = {
    lsp_format = "fallback",
    async = true,
  },
}
