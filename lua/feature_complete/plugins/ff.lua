local ff = require "ff"
ff.setup {
  fd_cmd = "fd --absolute-path --hidden --type f --exclude .git --exclude node_modules --exclude dist",
}

vim.api.nvim_set_hl(0, "FFPickerFuzzyHighlightChar", {
  fg = require "feature_complete.plugins.colorscheme".yellow,
  bold = true,
})
vim.api.nvim_set_hl(0, "FFPickerCursorLine", { link = "Visual", })

vim.keymap.set("n", "<leader>f", function()
  if vim.bo.filetype == "minifiles" then
    require "mini.files".close()
  end

  ff.find {
    keymaps = {
      n = {
        ["<cr>"] = "select",
        ["<c-n>"] = "next",
        ["<c-p>"] = "prev",
        ["<c-c>"] = "close",
        ["q"] = "close",
        ["<esc>"] = "close",
      },
      i = {
        ["<cr>"] = "select",
        ["<c-n>"] = "next",
        ["<c-p>"] = "prev",
        ["<c-c>"] = "close",
        ["<esc>"] = "close",
      },
    },
    on_picker_open = function(opts)
      vim.api.nvim_set_option_value("number", true, { win = opts.results_win, })
      vim.api.nvim_set_option_value("scrolloff", 0, { win = opts.results_win, })
      vim.api.nvim_buf_set_var(opts.input_buf, "minicompletion_disable", true)
    end,
  }
end)
