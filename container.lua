require "first"
require("helpers").utils.require_dir "shared"
require "barebones"

vim.g.clipboard = {
  name = "my-clipboard",
  copy = {
    ["+"] = { "nc", "--send-only", "host.docker.internal", vim.env.COPY_PORT },
    ["*"] = { "nc", "--send-only", "host.docker.internal", vim.env.COPY_PORT },
  },
  paste = {
    ["+"] = { "nc", "--recv-only", "host.docker.internal", vim.env.PASTE_PORT },
    ["*"] = { "nc", "--recv-only", "host.docker.internal", vim.env.PASTE_PORT },
  },
  cache_enabled = false,
}

vim.keymap.set({ "i", "n" }, "<C-w>", "<esc>:wq<cr>", { nowait = true })
vim.keymap.set({ "i", "n" }, "<C-t>", "<esc>:q!<cr>", { nowait = true })
