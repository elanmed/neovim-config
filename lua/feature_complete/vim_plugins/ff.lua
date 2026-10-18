vim.g.ff = {
  find_cmd = require("helpers").fd_cmd,
}

vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("FFResultsOpts", { clear = true }),
  pattern = "FFResultsOpen",
  callback = function(ev)
    local winnr = ev.data.winnr
    vim.api.nvim_win_set_config(winnr, { border = "single" })
    vim.wo[winnr].number = true
    vim.wo[winnr].scrolloff = 0
  end,
})

vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("FFPreviewOpts", { clear = true }),
  pattern = "FFPreviewOpen",
  callback = function(ev)
    local winnr = ev.data.winnr
    vim.wo[winnr].number = true
    vim.wo[winnr].scrolloff = 0
  end,
})

vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("FFInputOpts", { clear = true }),
  pattern = "FFInputOpen",
  callback = function(ev)
    local winnr = ev.data.winnr
    vim.api.nvim_win_set_config(winnr, { border = "single" })
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  group = vim.api.nvim_create_augroup("FFRemaps", { clear = true }),
  pattern = "ff-picker",
  callback = function()
    vim.keymap.set("i", "<cr>", "<Plug>FFResultSelect", { buffer = true })
    vim.keymap.set("i", "<c-n>", "<Plug>FFResultNext", { buffer = true })
    vim.keymap.set("i", "<c-p>", "<Plug>FFResultPrev", { buffer = true })
    vim.keymap.set(
      "i",
      "<c-x>",
      "<Plug>FFResultDeleteFrecencyScore",
      { buffer = true, nowait = true }
    )
    vim.keymap.set("i", "<esc>", "<Plug>FFClose", { buffer = true })
    vim.keymap.set("i", "<tab>", "<Plug>FFPreviewToggle", { buffer = true })
    vim.keymap.set("i", "<c-d>", "<Plug>FFPreviewScrollDown", { buffer = true })
    vim.keymap.set("i", "<c-u>", "<Plug>FFPreviewScrollUp", { buffer = true })
    vim.keymap.set("i", "<c-c>", "<Plug>FFInputClear", { buffer = true })
  end,
})

vim.keymap.set("n", "<leader>f", function()
  require("ff").find()
end)

vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("FFRefreshUserEvents", { clear = true }),
  pattern = {
    "TreeCreate",
    "TreeDelete",
    "TreeRename",
    "TreeMove",
    "TreeCopy",
    "GitHeadChanged",
  },
  callback = function()
    require("ff").refresh_files_cache()
  end,
})
