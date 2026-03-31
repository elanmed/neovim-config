vim.g.ff = {
  find_cmd = require "helpers".fd_cmd,
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
  auto_setup = false,
}

vim.api.nvim_create_autocmd({ "FileType", }, {
  group = vim.api.nvim_create_augroup("FFRemaps", { clear = true, }),
  pattern = "ff-picker",
  callback = function()
    vim.keymap.set("i", "<cr>", "<Plug>FFResultSelect", { buffer = true, })
    vim.keymap.set("i", "<c-n>", "<Plug>FFResultNext", { buffer = true, })
    vim.keymap.set("i", "<c-p>", "<Plug>FFResultPrev", { buffer = true, })
    vim.keymap.set("i", "<c-x>", "<Plug>FFResultDeleteFrecencyScore", { buffer = true, nowait = true, })
    vim.keymap.set("i", "<esc>", "<Plug>FFClose", { buffer = true, })
    vim.keymap.set("i", "<tab>", "<Plug>FFPreviewToggle", { buffer = true, })
    vim.keymap.set("i", "<c-d>", "<Plug>FFPreviewScrollDown", { buffer = true, })
    vim.keymap.set("i", "<c-u>", "<Plug>FFPreviewScrollUp", { buffer = true, })
  end,
})

vim.keymap.set("n", "<leader>f", function()
  local ff = require "ff"
  ff.setup(function() ff.find() end)
end)

vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("FFVimEnter", { clear = true, }),
  callback = function()
    local ff = require "ff"
    ff.setup(function() ff.find() end)
  end,
})

vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("FFRefreshUserEvents", { clear = true, }),
  pattern = {
    "TreeCreate",
    "TreeDelete",
    "TreeRename",
    "TreeMove",
    "TreeCopy",
    "GitHeadChanged",
  },
  callback = function()
    local ff = require "ff"
    ff.setup(function() ff.refresh_files_cache() end)
  end,
})

vim.keymap.set("n", "<leader>zl", function()
  require "fzf-lua-frecency".frecency {
    hidden = true,
    cwd_only = true,
  }
end)
