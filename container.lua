require "first"
require "helpers".utils.require_dir "shared"
require "barebones"

vim.g.clipboard = {
  name = "my-clipboard",
  copy = {
    ["+"] = { "nc", "--send-only", "host.docker.internal", vim.env.COPY_PORT, },
    ["*"] = { "nc", "--send-only", "host.docker.internal", vim.env.COPY_PORT, },
  },
  paste = {
    ["+"] = { "nc", "--recv-only", "host.docker.internal", vim.env.PASTE_PORT, },
    ["*"] = { "nc", "--recv-only", "host.docker.internal", vim.env.PASTE_PORT, },
  },
  cache_enabled = false,
}
