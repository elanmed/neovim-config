local snacks = require "snacks"

--- @type snacks.Config
snacks.setup {
  indent = { enabled = true, animate = { enabled = false, }, },
  explorer = { enabled = true, replace_netrw = false, },
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
    layout = {
      layout = {
        backdrop = false,
        row = -1,
        width = 0,
        height = 0.4,
        box = "vertical",
        { win = "input", height = 1, border = "rounded", },
        { win = "list", border = "none", },
      },
    },
    formatters = {
      file = {
        truncate = 100,
      },
    },
  }
end, { desc = "Find files with snacks", })
vim.keymap.set("n", "<leader>ln", function()
  snacks.picker.undo {
    layout = {
      layout = {
        backdrop = false,
        width = 0,
        height = 0.99, -- avoid cutting off the border
        box = "vertical",
        border = "none",
        title = "{title}",
        title_pos = "center",
        { win = "preview", height = 0.65, border = "rounded", },
        { win = "list", border = "none", },
        { win = "input", height = 1, border = "top", },
      },
    },
  }
end, { desc = "View the undotree with snacks", })
