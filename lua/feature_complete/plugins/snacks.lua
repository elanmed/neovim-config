local snacks = require "snacks"

snacks.setup {
  explorer = { enabled = true, replace_netrw = false, },
  bigfile = {},
  image = { enabled = true, },
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

vim.keymap.set("n", "/", function()
    if vim.bo.filetype == "minifiles" then
      vim.api.nvim_feedkeys("/", "n", false)
      return
    end

    snacks.picker.lines {
      layout = {
        layout = {
          backdrop = false,
          row = -1,
          width = 0,
          height = 0.5,
          box = "vertical",
          { win = "list", border = "rounded", },
          { win = "input", height = 1, border = "rounded", },
        },
      },
      on_show = function()
        vim.api.nvim_buf_set_var(vim.api.nvim_get_current_buf(), "minicompletion_disable", true)
      end,
      on_close = function()
        -- vim.schedule(function()
        --   star_curr_word()
        -- end)
      end,
    }
  end,
  { desc = "Search in the current buffer with snacks", })

vim.keymap.set("n", "<leader>l", function()
    snacks.picker.undo {
      layout = {
        layout = {
          backdrop = false,
          width = 0,
          height = 0.95,
          box = "vertical",
          border = "none",
          { win = "preview", height = 0.65, border = "rounded", },
          { win = "list", border = "rounded", },
          { win = "input", height = 1, border = "rounded", },
        },
      },
    }
  end,
  { desc = "View the undotree with snacks", })
