local ff = require "ff"
ff.setup {
  find_cmd = "fd --absolute-path --hidden --type f --exclude .git --exclude node_modules --exclude dist",
}

vim.api.nvim_set_hl(0, "FFPickerFuzzyHighlightChar", {
  fg = require "feature_complete.plugins.colorscheme".yellow,
  bold = true,
})
vim.api.nvim_set_hl(0, "FFPickerCursorLine", { link = "Visual", })

vim.keymap.set("n", "<leader>f", function()
  if vim.bo.filetype == "tree" then
    vim.cmd "close"
  end

  ff.find {
    get_max_results_considered = function() return 1000 end,
    keymaps = {
      i = {
        ["<cr>"] = "select",
        ["<c-n>"] = "next",
        ["<c-p>"] = "prev",
        ["<c-c>"] = "close",
        ["<esc>"] = "close",
        ["<tab>"] = "preview-toggle",
        ["<C-d>"] = "preview-scroll-down",
        ["<C-u>"] = "preview-scroll-up",
      },
    },
    on_picker_open = function()
      vim.b.completion = false
    end,
    results_win_opts = {
      number = true,
      scrolloff = 0,
    },
    preview_win_opts = {
      number = true,
      scrolloff = 0,
    },
  }
end)

vim.api.nvim_create_autocmd("User", {
  pattern = {
    "MiniFilesActionCreate",
    "MiniFilesActionDelete",
    "MiniFilesActionRename",
    "MiniFilesActionCopy",
    "MiniFilesActionMove",
  },
  callback = function()
    ff.refresh_files_cache()
  end,
})
