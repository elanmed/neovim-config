--- @type vim.lsp.Config
return {
  settings = {
    bashIde = { shellcheckArguments = "--extended-analysis=false", shfmt = { simplifyCode = true, caseIndent = true, }, },
  },
}
