vim.opt.rtp:prepend(vim.fn.getcwd())
vim.opt.rtp:append "deps/mini.test"
require("mini.test").setup()
