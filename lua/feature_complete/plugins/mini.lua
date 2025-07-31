require "mini.surround".setup {
  mappings = {
    add = "ys",
    delete = "ds",
    find = "",
    find_left = "",
    highlight = "",
    replace = "cs",
    update_n_lines = "",
    suffix_last = "",
    suffix_next = "",
  },
  search_method = "cover_or_next",
}

require "mini.indentscope".setup()
require "mini.icons".setup()
require "mini.move".setup()
require "mini.operators".setup {
  evaluate = { prefix = "", },
  sort = { prefix = "", },
}
require "mini.notify".setup {
  lsp_progress = {
    duration_last = 5000,
  },
}
