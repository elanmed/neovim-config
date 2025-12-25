vim.filetype.add { extension = { mdx = "mdx", }, }
vim.treesitter.language.register("markdown", "mdx")

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true, }),
  callback = function() pcall(vim.treesitter.start) end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("TreesitterInstall", { clear = true, }),
  callback = function(event)
    local treesitter = require "nvim-treesitter"
    local filetype = event.match
    local lang = vim.treesitter.language.get_lang(filetype)
    if lang == nil then return end

    local is_installed = vim.treesitter.language.add(lang)

    if not is_installed then
      local available_langs = treesitter.get_available()

      if vim.tbl_contains(available_langs, lang) then
        treesitter.install { lang, }
      end
    end

    pcall(vim.treesitter.start, event.buf, lang)
  end,
})

vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("TreesitterUpdate", { clear = true, }),
  pattern = "nvim-treesitter",
  callback = function()
    require "helpers".notify.doing "Updating treesitter parsers"
    require "nvim-treesitter".update(nil, { summary = true, })
  end,
})
