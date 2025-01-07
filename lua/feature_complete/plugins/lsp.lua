local h = require "shared.helpers"
local autopairs = require "nvim-autopairs"
autopairs.setup { map_cr = false, }

-- https://github.com/samhvw8/mvim/blob/master/lua/core/coc.lua
h.let.coc_global_extensions = {
  "coc-tsserver",
  "coc-prettier",
  "coc-json",
  "coc-eslint",
  -- "coc-snippets",
  "coc-sumneko-lua",
  "coc-sh",
  "@yaegassy/coc-tailwindcss3",
  "coc-cssmodules",
  "coc-deno",
  "coc-stylelint",
  "coc-css",
  "coc-highlight",
  "coc-solargraph",
}

local function coc_show_docs()
  local cw = vim.fn.expand "<cword>"
  if h.tbl.table_contains_value({ "vim", "help", }, vim.bo.filetype) then
    vim.cmd("h " .. cw)
  elseif vim.api.nvim_eval "coc#rpc#ready()" then
    vim.fn.CocActionAsync "doHover"
  else
    vim.cmd("!" .. vim.o.keywordprg .. " " .. cw)
  end
end

h.keys.map({ "i", }, "<C-s>", "coc#refresh()", { expr = true, desc = "Show autocompletion options", })
-- issues when written in lua
vim.cmd [[
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() :
	\ "\<CMD>call feedkeys(v:lua.require('nvim-autopairs').autopairs_cr(), 'in')\<CR>"
]]

h.keys.map({ "n", }, "gd", "<Plug>(coc-definition)zz", { desc = "Go to definition", })
h.keys.map({ "n", }, "gy", "<Plug>(coc-type-definition)", { desc = "Go to type definition", })
h.keys.map({ "n", }, "gu", "<Plug>(coc-references)", { desc = "Go to uses", })
h.keys.map({ "n", }, "ga", "<Plug>(coc-codeaction-cursor)", { desc = "Open code actions", })
h.keys.map({ "n", }, "gh", coc_show_docs, { desc = "Hover", })

h.keys.map({ "n", }, "gl", function()
  if vim.fn["coc#float#has_float"]() == 1 then
    vim.fn["coc#float#close_all"]()
  end
end, { desc = "Close hover", })
h.keys.map({ "n", }, "<leader>cr", h.keys.user_cmd_cb "CocRestart", { desc = "Restart coc", })

h.set.updatetime = 100
h.set.signcolumn = "yes" -- needed for linting symbols

vim.api.nvim_create_augroup("CocGroup", {})
vim.api.nvim_create_autocmd({ "CursorHold", }, {
  group = "CocGroup",
  callback = function()
    if not h.tbl.table_contains_value({ "qf", "DiffviewFiles", "oil", "harpoon", }, vim.bo.filetype) then
      vim.cmd "silent call CocActionAsync('highlight')"
    end
  end,
})
