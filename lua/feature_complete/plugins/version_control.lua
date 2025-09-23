local mini_diff = require "mini.diff"
mini_diff.setup {
  mappings = {
    apply = "",
    reset = "gh",
    goto_first = "",
    goto_next = "<C-j>",
    goto_prev = "<C-k>",
    goto_last = "",
  },
}

vim.keymap.set("n", "<C-b>", mini_diff.toggle_overlay, { desc = "Toggle mini diff overlay", })
