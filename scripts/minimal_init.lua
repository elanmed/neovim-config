vim.opt.rtp:prepend(vim.fn.getcwd())
vim.opt.rtp:append "deps/mini.test"
require("mini.test").setup {
  collect = {
    find_files = function()
      local test_files = vim.fn.globpath("tests", "**/*_test.lua", true, true)
      vim.list_extend(test_files, vim.fn.globpath("tests", "**/test_*.lua", true, true))
      return test_files
    end,
  },
}
