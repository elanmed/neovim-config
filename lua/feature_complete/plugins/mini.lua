require "mini.surround".setup()
require "mini.indentscope".setup()
require "mini.icons".setup()
require "mini.move".setup()
require "mini.operators".setup {
  evaluate = { prefix = "", },
  sort = { prefix = "", },
}
