vim.g.ff = {
  find_cmd = "fd --absolute-path --hidden --type f --exclude .git --exclude node_modules --exclude dist",
  results_win_config = {
    border = "single",
  },
  input_win_config = {
    border = "single",
  },
  results_win_opts = {
    number = true,
    scrolloff = 0,
  },
  preview_win_opts = {
    number = true,
    scrolloff = 0,
  },
  on_picker_open = function()
    vim.api.nvim_set_hl(0, "FFPickerFuzzyHighlightChar", {
      fg = require "feature_complete.plugins.colorscheme".yellow,
      bold = true,
    })
    vim.api.nvim_set_hl(0, "FFPickerCursorLine", { link = "Visual", })
  end,
}

vim.api.nvim_create_autocmd({ "FileType", }, {
  group = vim.api.nvim_create_augroup("FFRemaps", { clear = true, }),
  pattern = "ff-picker",
  callback = function()
    vim.keymap.set("i", "<cr>", "<Plug>FFResultSelect", { buffer = true, })
    vim.keymap.set("i", "<c-n>", "<Plug>FFResultNext", { buffer = true, })
    vim.keymap.set("i", "<c-p>", "<Plug>FFResultPrev", { buffer = true, })
    vim.keymap.set("i", "<c-x>", "<Plug>FFResultDeleteFrecencyScore", { buffer = true, nowait = true, })
    vim.keymap.set("i", "<c-c>", "<Plug>FFClose", { buffer = true, })
    vim.keymap.set("i", "<esc>", "<Plug>FFClose", { buffer = true, })
    vim.keymap.set("i", "<tab>", "<Plug>FFPreviewToggle", { buffer = true, })
    vim.keymap.set("i", "<c-d>", "<Plug>FFPreviewScrollDown", { buffer = true, })
    vim.keymap.set("i", "<c-u>", "<Plug>FFPreviewScrollUp", { buffer = true, })
  end,
})

local ff = require "ff"
vim.keymap.set("n", "<leader>f", function()
  if vim.bo.filetype == "tree" then
    vim.cmd.close()
  end

  ff.find()
end)

vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("TreeUserEvents", { clear = true, }),
  pattern = {
    "TreeCreate",
    "TreeDelete",
    "TreeRename",
  },
  callback = function() ff.refresh_files_cache() end,
})

vim.keymap.set("n", "<leader>zl", function()
  require "fzf-lua-frecency".frecency {
    hidden = true,
    cwd_only = true,
  }
end)
