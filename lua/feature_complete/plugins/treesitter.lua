local h = require "helpers"

vim.filetype.add { extension = { mdx = "mdx", }, }
vim.treesitter.language.register("markdown", "mdx")

vim.api.nvim_create_autocmd("FileType", {
  callback = function() pcall(vim.treesitter.start) end,
})

local treesitter = require "nvim-treesitter"

vim.api.nvim_create_autocmd("FileType", {
  callback = function(event)
    local filetype = event.match
    local lang = vim.treesitter.language.get_lang(filetype)
    if lang == nil then return end

    local is_installed = vim.treesitter.language.add(lang)

    if not is_installed then
      local available_langs = treesitter.get_available()

      if vim.tbl_contains(available_langs, lang) then
        treesitter.install { lang, }:wait(30 * 1000)
      end
    end

    pcall(vim.treesitter.start, event.buf, lang)
  end,
})

vim.api.nvim_create_autocmd("PackChanged", {
  pattern = "nvim-treesitter",
  callback = function()
    h.notify.doing "Updating treesitter parsers"
    treesitter.update(nil, { summary = true, })
  end,
})
