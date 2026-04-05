local M = {
  black = "#1d1f21",
  extra_dark_grey = "#282a2e",
  dark_grey = "#373b41",
  grey = "#969896",
  light_grey = "#b4b7b4",
  extra_light_grey = "#c5c8c6",
  dark_white = "#e0e0e0",
  white = "#ffffff",
  red = "#cc6666",
  orange = "#de935f",
  yellow = "#f0c674",
  green = "#b5bd68",
  cyan = "#8abeb7",
  blue = "#81a2be",
  purple = "#b294bb",
  brown = "#a3685a",
}

if vim.g.colors_name then
  vim.cmd "highlight clear"
end
vim.g.colors_name = nil

-- Builtin highlighting groups
vim.api.nvim_set_hl(0, "ColorColumn", { bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "ComplMatchIns", {})
vim.api.nvim_set_hl(0, "Conceal", { fg = M.blue, })
vim.api.nvim_set_hl(0, "CurSearch", { fg = M.extra_dark_grey, bg = M.orange, })
vim.api.nvim_set_hl(0, "Cursor", { fg = M.black, bg = M.extra_light_grey, })
vim.api.nvim_set_hl(0, "CursorColumn", { bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "CursorIM", { fg = M.black, bg = M.extra_light_grey, })
vim.api.nvim_set_hl(0, "CursorLine", { bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "CursorLineFold", { fg = M.cyan, bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = M.light_grey, bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "CursorLineSign", { fg = M.grey, bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "DiffAdd", { fg = M.green, bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "DiffChange", { fg = M.purple, bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "DiffDelete", { fg = M.red, bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "DiffText", { fg = M.blue, bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "DiffTextAdd", { link = "DiffAdd", })
vim.api.nvim_set_hl(0, "DiffSignAdd", { fg = M.green, bg = M.dark_grey, bold = true, })
vim.api.nvim_set_hl(0, "DiffSignChange", { fg = M.yellow, bg = M.dark_grey, bold = true, })
vim.api.nvim_set_hl(0, "DiffSignDelete", { fg = M.red, bg = M.dark_grey, bold = true, })
vim.api.nvim_set_hl(0, "Directory", { fg = M.blue, })
vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = M.grey, })
vim.api.nvim_set_hl(0, "ErrorMsg", { fg = M.red, })
vim.api.nvim_set_hl(0, "FloatBorder", { link = "NormalFloat", })
vim.api.nvim_set_hl(0, "FoldColumn", { fg = M.cyan, bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "Folded", { fg = M.grey, bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "IncSearch", { fg = M.extra_dark_grey, bg = M.orange, })
vim.api.nvim_set_hl(0, "lCursor", { fg = M.black, bg = M.extra_light_grey, })
vim.api.nvim_set_hl(0, "LineNr", { fg = M.grey, bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "LineNrAbove", { fg = M.grey, bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "LineNrBelow", { fg = M.grey, bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "MatchParen", { bg = M.dark_grey, })
vim.api.nvim_set_hl(0, "ModeMsg", { fg = M.green, })
vim.api.nvim_set_hl(0, "MoreMsg", { fg = M.green, })
vim.api.nvim_set_hl(0, "MsgArea", { link = "Normal", })
vim.api.nvim_set_hl(0, "MsgSeparator", { fg = M.dark_grey, bg = M.dark_grey, })
vim.api.nvim_set_hl(0, "NonText", { fg = M.grey, })
vim.api.nvim_set_hl(0, "Normal", { fg = M.extra_light_grey, bg = M.black, })
vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal", })
vim.api.nvim_set_hl(0, "NormalNC", { fg = M.extra_light_grey, bg = M.black, })
vim.api.nvim_set_hl(0, "OkMsg", { fg = M.green, })
vim.api.nvim_set_hl(0, "Pmenu", { link = "Normal", })
vim.api.nvim_set_hl(0, "PmenuExtra", { link = "Pmenu", })
vim.api.nvim_set_hl(0, "PmenuExtraSel", { link = "PmenuSel", })
vim.api.nvim_set_hl(0, "PmenuKind", { link = "Pmenu", })
vim.api.nvim_set_hl(0, "PmenuKindSel", { link = "PmenuSel", })
vim.api.nvim_set_hl(0, "PmenuMatch", { fg = M.extra_light_grey, bold = true, })
vim.api.nvim_set_hl(0, "PmenuMatchSel", { fg = M.extra_light_grey, bold = true, reverse = true, })
vim.api.nvim_set_hl(0, "PmenuSbar", { bg = M.dark_grey, })
vim.api.nvim_set_hl(0, "PmenuSel", { fg = M.extra_light_grey, bg = M.extra_dark_grey, reverse = true, })
vim.api.nvim_set_hl(0, "PmenuThumb", { bg = M.white, })
vim.api.nvim_set_hl(0, "Question", { fg = M.blue, })
vim.api.nvim_set_hl(0, "QuickFixLine", { bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "Search", { fg = M.extra_dark_grey, bg = M.yellow, })
vim.api.nvim_set_hl(0, "SignColumn", { fg = M.grey, bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "SpecialKey", { fg = M.grey, })
vim.api.nvim_set_hl(0, "SpellBad", { undercurl = true, sp = M.red, })
vim.api.nvim_set_hl(0, "SpellCap", { undercurl = true, sp = M.blue, })
vim.api.nvim_set_hl(0, "SpellLocal", { undercurl = true, sp = M.cyan, })
vim.api.nvim_set_hl(0, "SpellRare", { undercurl = true, sp = M.purple, })
vim.api.nvim_set_hl(0, "StatusLine", { fg = M.light_grey, bg = M.dark_grey, })
vim.api.nvim_set_hl(0, "StatusLineNC", { fg = M.grey, bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "StderrMsg", { link = "ErrorMsg", })
vim.api.nvim_set_hl(0, "StdoutMsg", { link = "MsgArea", })
vim.api.nvim_set_hl(0, "Substitute", { fg = M.extra_dark_grey, bg = M.yellow, })
vim.api.nvim_set_hl(0, "TabLine", { fg = M.grey, bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "TabLineFill", { fg = M.grey, bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "TabLineSel", { fg = M.green, bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "TabLineTitle", { fg = M.yellow, bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "TermCursor", { reverse = true, })
vim.api.nvim_set_hl(0, "TermCursorNC", { reverse = true, })
vim.api.nvim_set_hl(0, "Title", { fg = M.blue, })
vim.api.nvim_set_hl(0, "VertSplit", { fg = M.dark_grey, bg = M.dark_grey, })
vim.api.nvim_set_hl(0, "Visual", { bg = M.dark_grey, })
vim.api.nvim_set_hl(0, "VisualNOS", { fg = M.red, })
vim.api.nvim_set_hl(0, "WarningMsg", { fg = M.red, })
vim.api.nvim_set_hl(0, "Whitespace", { fg = M.dark_grey, })
vim.api.nvim_set_hl(0, "WildMenu", { fg = M.yellow, bg = M.dark_grey, bold = true, })
vim.api.nvim_set_hl(0, "WinBar", { fg = M.light_grey, bg = M.dark_grey, })
vim.api.nvim_set_hl(0, "WinBarNC", { fg = M.grey, bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "WinSeparator", { fg = M.dark_grey, bg = M.dark_grey, })

-- Standard syntax
vim.api.nvim_set_hl(0, "Boolean", { fg = M.orange, })
vim.api.nvim_set_hl(0, "Character", { fg = M.red, })
vim.api.nvim_set_hl(0, "Comment", { fg = M.grey, })
vim.api.nvim_set_hl(0, "Conditional", { fg = M.purple, })
vim.api.nvim_set_hl(0, "Constant", { fg = M.orange, })
vim.api.nvim_set_hl(0, "Debug", { fg = M.red, })
vim.api.nvim_set_hl(0, "Define", { fg = M.purple, })
vim.api.nvim_set_hl(0, "Delimiter", { fg = M.brown, })
vim.api.nvim_set_hl(0, "Error", { fg = M.black, bg = M.red, })
vim.api.nvim_set_hl(0, "Exception", { fg = M.red, })
vim.api.nvim_set_hl(0, "Float", { fg = M.orange, })
vim.api.nvim_set_hl(0, "Function", { fg = M.purple, })
vim.api.nvim_set_hl(0, "Identifier", { fg = M.extra_light_grey, })
vim.api.nvim_set_hl(0, "Ignore", { fg = M.cyan, })
vim.api.nvim_set_hl(0, "Include", { fg = M.blue, })
vim.api.nvim_set_hl(0, "Keyword", { fg = M.purple, })
vim.api.nvim_set_hl(0, "Label", { fg = M.yellow, })
vim.api.nvim_set_hl(0, "Macro", { fg = M.red, })
vim.api.nvim_set_hl(0, "Number", { fg = M.orange, })
vim.api.nvim_set_hl(0, "Operator", { fg = M.brown, })
vim.api.nvim_set_hl(0, "PreCondit", { fg = M.yellow, })
vim.api.nvim_set_hl(0, "PreProc", { fg = M.yellow, })
vim.api.nvim_set_hl(0, "Repeat", { fg = M.purple, })
vim.api.nvim_set_hl(0, "Special", { fg = M.cyan, })
vim.api.nvim_set_hl(0, "SpecialChar", { fg = M.brown, })
vim.api.nvim_set_hl(0, "SpecialComment", { fg = M.cyan, })
vim.api.nvim_set_hl(0, "Statement", { fg = M.purple, })
vim.api.nvim_set_hl(0, "StorageClass", { fg = M.yellow, })
vim.api.nvim_set_hl(0, "String", { fg = M.green, })
vim.api.nvim_set_hl(0, "Structure", { fg = M.grey, })
vim.api.nvim_set_hl(0, "Tag", { fg = M.yellow, })
vim.api.nvim_set_hl(0, "Todo", { fg = M.yellow, bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "Type", { fg = M.yellow, })
vim.api.nvim_set_hl(0, "Typedef", { fg = M.yellow, })

-- Other
vim.api.nvim_set_hl(0, "Bold", { bold = true, })
vim.api.nvim_set_hl(0, "Italic", { italic = true, })
vim.api.nvim_set_hl(0, "TooLong", { fg = M.red, })
vim.api.nvim_set_hl(0, "Underlined", { underline = true, })

-- Patch diff
vim.api.nvim_set_hl(0, "diffAdded", { fg = M.green, })
vim.api.nvim_set_hl(0, "diffChanged", { fg = M.purple, })
vim.api.nvim_set_hl(0, "diffFile", { fg = M.orange, })
vim.api.nvim_set_hl(0, "diffLine", { fg = M.cyan, })
vim.api.nvim_set_hl(0, "diffRemoved", { fg = M.red, })
vim.api.nvim_set_hl(0, "Added", { fg = M.green, })
vim.api.nvim_set_hl(0, "Changed", { fg = M.purple, })
vim.api.nvim_set_hl(0, "Removed", { fg = M.red, })

-- Git commit
vim.api.nvim_set_hl(0, "gitcommitBranch", { fg = M.orange, bold = true, })
vim.api.nvim_set_hl(0, "gitcommitComment", { link = "Comment", })
vim.api.nvim_set_hl(0, "gitcommitDiscarded", { link = "Comment", })
vim.api.nvim_set_hl(0, "gitcommitDiscardedFile", { fg = M.red, bold = true, })
vim.api.nvim_set_hl(0, "gitcommitDiscardedType", { fg = M.blue, })
vim.api.nvim_set_hl(0, "gitcommitHeader", { fg = M.purple, })
vim.api.nvim_set_hl(0, "gitcommitOverflow", { fg = M.red, })
vim.api.nvim_set_hl(0, "gitcommitSelected", { link = "Comment", })
vim.api.nvim_set_hl(0, "gitcommitSelectedFile", { fg = M.green, bold = true, })
vim.api.nvim_set_hl(0, "gitcommitSelectedType", { link = "gitcommitDiscardedType", })
vim.api.nvim_set_hl(0, "gitcommitSummary", { fg = M.green, })
vim.api.nvim_set_hl(0, "gitcommitUnmergedFile", { link = "gitcommitDiscardedFile", })
vim.api.nvim_set_hl(0, "gitcommitUnmergedType", { link = "gitcommitDiscardedType", })
vim.api.nvim_set_hl(0, "gitcommitUntracked", { link = "Comment", })
vim.api.nvim_set_hl(0, "gitcommitUntrackedFile", { fg = M.yellow, })

-- Built-in diagnostic
vim.api.nvim_set_hl(0, "DiagnosticError", { fg = M.red, })
vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = M.blue, })
vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = M.cyan, })
vim.api.nvim_set_hl(0, "DiagnosticOk", { fg = M.green, })
vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = M.purple, })

vim.api.nvim_set_hl(0, "DiagnosticFloatingError", { fg = M.red, bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "DiagnosticFloatingHint", { fg = M.blue, bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "DiagnosticFloatingInfo", { fg = M.cyan, bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "DiagnosticFloatingOk", { fg = M.green, bg = M.extra_dark_grey, })
vim.api.nvim_set_hl(0, "DiagnosticFloatingWarn", { fg = M.purple, bg = M.extra_dark_grey, })

vim.api.nvim_set_hl(0, "DiagnosticSignError", { link = "DiagnosticFloatingError", })
vim.api.nvim_set_hl(0, "DiagnosticSignHint", { link = "DiagnosticFloatingHint", })
vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { link = "DiagnosticFloatingInfo", })
vim.api.nvim_set_hl(0, "DiagnosticSignOk", { link = "DiagnosticFloatingOk", })
vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { link = "DiagnosticFloatingWarn", })

vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { underline = true, sp = M.red, })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { underline = true, sp = M.blue, })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { underline = true, sp = M.cyan, })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineOk", { underline = true, sp = M.green, })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { underline = true, sp = M.purple, })

-- Built-in LSP
vim.api.nvim_set_hl(0, "LspReferenceText", { bg = M.dark_grey, })
vim.api.nvim_set_hl(0, "LspReferenceRead", { link = "LspReferenceText", })
vim.api.nvim_set_hl(0, "LspReferenceWrite", { link = "LspReferenceText", })

vim.api.nvim_set_hl(0, "LspSignatureActiveParameter", { link = "LspReferenceText", })

vim.api.nvim_set_hl(0, "LspCodeLens", { link = "Comment", })
vim.api.nvim_set_hl(0, "LspCodeLensSeparator", { link = "Comment", })

-- Built-in snippets
vim.api.nvim_set_hl(0, "SnippetTabstop", { link = "Visual", })
vim.api.nvim_set_hl(0, "SnippetTabstopActive", { link = "SnippetTabstop", })

-- Built-in markdown syntax
vim.api.nvim_set_hl(0, "markdownH1", { fg = M.orange, })
vim.api.nvim_set_hl(0, "markdownH2", { fg = M.yellow, })
vim.api.nvim_set_hl(0, "markdownH3", { fg = M.green, })
vim.api.nvim_set_hl(0, "markdownH4", { fg = M.cyan, })
vim.api.nvim_set_hl(0, "markdownH5", { fg = M.blue, })
vim.api.nvim_set_hl(0, "markdownH6", { fg = M.brown, })

-- Tree-sitter
vim.api.nvim_set_hl(0, "@keyword.return", { fg = M.red, })
vim.api.nvim_set_hl(0, "@symbol", { fg = M.purple, })
vim.api.nvim_set_hl(0, "@variable", { fg = M.extra_light_grey, })

vim.api.nvim_set_hl(0, "@field", { link = "@variable", })
vim.api.nvim_set_hl(0, "@function", { link = "@variable", })
vim.api.nvim_set_hl(0, "@method", { link = "@variable", })
vim.api.nvim_set_hl(0, "@property", { link = "@variable", })
vim.api.nvim_set_hl(0, "@variable.builtin", { link = "@variable", })
vim.api.nvim_set_hl(0, "@variable.parameter.builtin", { link = "@variable", })

vim.api.nvim_set_hl(0, "@text.strong", { bold = true, })
vim.api.nvim_set_hl(0, "@text.emphasis", { italic = true, })
vim.api.nvim_set_hl(0, "@text.strike", { strikethrough = true, })
vim.api.nvim_set_hl(0, "@text.underline", { link = "Underlined", })

-- Semantic tokens
vim.api.nvim_set_hl(0, "@lsp.type.variable", { fg = M.extra_light_grey, })
vim.api.nvim_set_hl(0, "@lsp.type.function", { link = "@variable", })
vim.api.nvim_set_hl(0, "@lsp.type.method", { link = "@variable", })
vim.api.nvim_set_hl(0, "@lsp.type.property", { link = "@variable", })
vim.api.nvim_set_hl(0, "@lsp.mod.deprecated", { fg = M.red, })

-- Tree-sitter markup groups
vim.api.nvim_set_hl(0, "@markup.strong", { link = "@text.strong", })
vim.api.nvim_set_hl(0, "@markup.italic", { link = "@text.emphasis", })
vim.api.nvim_set_hl(0, "@markup.strikethrough", { link = "@text.strike", })
vim.api.nvim_set_hl(0, "@markup.underline", { link = "@text.underline", })

vim.api.nvim_set_hl(0, "@markup.heading.1", { link = "markdownH1", })
vim.api.nvim_set_hl(0, "@markup.heading.2", { link = "markdownH2", })
vim.api.nvim_set_hl(0, "@markup.heading.3", { link = "markdownH3", })
vim.api.nvim_set_hl(0, "@markup.heading.4", { link = "markdownH4", })
vim.api.nvim_set_hl(0, "@markup.heading.5", { link = "markdownH5", })
vim.api.nvim_set_hl(0, "@markup.heading.6", { link = "markdownH6", })

vim.api.nvim_set_hl(0, "@string.special.vimdoc", { link = "SpecialChar", })
vim.api.nvim_set_hl(0, "@variable.parameter.vimdoc", { fg = M.orange, })
vim.api.nvim_set_hl(0, "@markup.heading.4.vimdoc", { link = "Title", })

-- mini.icons
vim.api.nvim_set_hl(0, "MiniIconsAzure", { fg = M.blue, })
vim.api.nvim_set_hl(0, "MiniIconsBlue", { fg = M.brown, })
vim.api.nvim_set_hl(0, "MiniIconsCyan", { fg = M.cyan, })
vim.api.nvim_set_hl(0, "MiniIconsGreen", { fg = M.green, })
vim.api.nvim_set_hl(0, "MiniIconsGrey", { fg = M.white, })
vim.api.nvim_set_hl(0, "MiniIconsOrange", { fg = M.orange, })
vim.api.nvim_set_hl(0, "MiniIconsPurple", { fg = M.purple, })
vim.api.nvim_set_hl(0, "MiniIconsRed", { fg = M.red, })
vim.api.nvim_set_hl(0, "MiniIconsYellow", { fg = M.yellow, })

-- plugins
vim.api.nvim_set_hl(0, "FFPickerCursorLine", { link = "Visual", })
vim.api.nvim_set_hl(0, "FFPickerFuzzyHighlightChar", { fg = M.yellow, bold = true, })
vim.api.nvim_set_hl(0, "MarkCol", { fg = M.yellow, bold = true, })
vim.api.nvim_set_hl(0, "MarkRow", { fg = M.yellow, })

-- custom overrides
vim.api.nvim_set_hl(0, "NotifyDebug", { fg = M.orange, })
vim.api.nvim_set_hl(0, "NotifyError", { fg = M.red, })
vim.api.nvim_set_hl(0, "NotifyInfo", { fg = M.blue, })
vim.api.nvim_set_hl(0, "NotifyOff", { fg = M.purple, })
vim.api.nvim_set_hl(0, "NotifyTrace", { fg = M.green, })
vim.api.nvim_set_hl(0, "NotifyWarn", { fg = M.yellow, })

-- HTML syntax
vim.api.nvim_set_hl(0, "htmlTag", { link = "Tag", })
vim.api.nvim_set_hl(0, "htmlTagName", { link = "Tag", })
vim.api.nvim_set_hl(0, "tsxTag", { link = "Tag", })
vim.api.nvim_set_hl(0, "tsxTagName", { link = "Tag", })
vim.api.nvim_set_hl(0, "jsxTagName", { link = "Tag", })
vim.api.nvim_set_hl(0, "jsxTag", { link = "Tag", })
vim.api.nvim_set_hl(0, "tsxComponentName", { link = "Tag", })
vim.api.nvim_set_hl(0, "jsxComponentName", { link = "Tag", })

-- Terminal colors
vim.g.terminal_color_0 = M.black
vim.g.terminal_color_1 = M.red
vim.g.terminal_color_2 = M.green
vim.g.terminal_color_3 = M.yellow
vim.g.terminal_color_4 = M.blue
vim.g.terminal_color_5 = M.purple
vim.g.terminal_color_6 = M.cyan
vim.g.terminal_color_7 = M.extra_light_grey
vim.g.terminal_color_8 = M.grey
vim.g.terminal_color_9 = M.red
vim.g.terminal_color_10 = M.green
vim.g.terminal_color_11 = M.yellow
vim.g.terminal_color_12 = M.blue
vim.g.terminal_color_13 = M.purple
vim.g.terminal_color_14 = M.cyan
vim.g.terminal_color_15 = M.white

return M
