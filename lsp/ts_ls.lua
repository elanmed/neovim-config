--- @type vim.lsp.Config
return {
  init_options = {
    preferences = {
      importModuleSpecifierPreference = "non-relative",
      jsxAttributeCompletionStyle = "braces",
      includeCompletionsWithSnippetText = false,
    },
  },
}
