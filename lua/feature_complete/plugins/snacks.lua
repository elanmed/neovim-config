local snacks = require "snacks"

snacks.setup {
  indent = { enabled = true, animate = { enabled = false, }, },
  explorer = { enabled = true, replace_netrw = false, },
  bigfile = {},
  picker = {
    win = {
      input = {
        keys = {
          ["<Esc>"] = { "close", mode = "i", },
          ["<C-c>"] = { "close", mode = "i", },
          ["<C-u>"] = { "preview_scroll_up", mode = { "i", "n", }, },
          ["<C-d>"] = { "preview_scroll_down", mode = { "i", "n", }, },
        },
      },
    },
  },
}

vim.keymap.set("n", "<C-p>", function()
  snacks.picker.smart {
    hidden = true,
    layout = {
      layout = {
        backdrop = false,
        row = 0,
        width = 0.8,
        height = 0.4,
        box = "vertical",
        border = "rounded",
        { win = "input", height = 1, border = "bottom", },
        { win = "list", },
      },
    },
    formatters = {
      file = {
        truncate = 100,
      },
    },
  }
end, { desc = "Find files with snacks", })

local function star_curr_word()
  local word = vim.fn.expand "<cword>"
  -- https://superuser.com/a/299693
  vim.cmd([[let @/ = '\<]] .. word .. [[\>']])
  vim.api.nvim_set_option_value("hlsearch", true, {})
end

vim.keymap.set("n", "*", star_curr_word, { silent = true, desc = "*, but stay on the current search result", })
vim.keymap.set("n", "/", function()
    snacks.picker.lines {
      layout = {
        layout = {
          backdrop = false,
          row = -1,
          width = 0,
          height = 0.4,
          box = "vertical",
          { win = "input", height = 1, border = "rounded", },
          { win = "list", },
        },
      },
      on_close = function()
        vim.schedule(function()
          star_curr_word()
        end)
      end,
    }
  end,
  { desc = "Search in the current buffer with snacks", })

vim.keymap.set("n", "<leader>ln", function()
    snacks.picker.undo {
      layout = {
        layout = {
          backdrop = false,
          width = 0,
          height = 0.99, -- avoid cutting off the border
          box = "vertical",
          border = "none",
          { win = "preview", height = 0.65, border = "rounded", },
          { win = "list", },
          { win = "input", height = 1, border = "top", },
        },
      },
    }
  end,
  { desc = "View the undotree with snacks", })
