--- @type vim.lsp.Config
return {
  filetypes = { "bash", "sh", "zsh" },
  settings = {
    bashIde = {
      shellcheckArguments = "--extended-analysis=false",
      shfmt = { simplifyCode = true, caseIndent = true },
    },
  },
}
