local h = require "helpers"
h.utils.lazy_setup(function()
  local icons = require "mini.icons"
  icons.setup()
  icons.tweak_lsp_kind()
end)
h.utils.lazy_setup(function() require "mini.splitjoin".setup() end)
