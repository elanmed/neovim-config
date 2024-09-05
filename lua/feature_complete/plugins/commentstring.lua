local h = require "shared.helpers"

return {
  "JoosepAlviste/nvim-ts-context-commentstring",
  commit = "375c2d8",
  config = function()
    h.let.skip_ts_context_commentstring_module = true
  end,
  opts = {
    enable_autocmd = false,
  }
}
