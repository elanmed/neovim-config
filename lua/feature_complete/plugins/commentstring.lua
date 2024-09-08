local h = require "shared.helpers"

h.let.skip_ts_context_commentstring_module = true

return {
  "JoosepAlviste/nvim-ts-context-commentstring",
  commit = "375c2d8",
  lazy = true,
  opts = {
    enable_autocmd = false,
  }
}
