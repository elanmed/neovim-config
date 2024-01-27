local commentstring = require('ts_context_commentstring')
local h = require "shared.helpers"

h.let.skip_ts_context_commentstring_module = true
commentstring.setup {
  enable_autocmd = false,
}
