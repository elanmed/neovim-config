-- vim.keymap.set("n", "<C-f>", function()
--   require "tree".tree {
--     tree_win_config = {
--       border = "single",
--     },
--     tree_win_opts = {
--       relativenumber = true,
--     },
--   }
-- end, { desc = "Toggle tree", })
--
-- vim.api.nvim_create_autocmd("FileType", {
--   group = vim.api.nvim_create_augroup("TreeRemaps", { clear = true, }),
--   pattern = "tree",
--   callback = function(args)
--     vim.b.minicursorword_disable = true
--     vim.keymap.set("n", "<cr>", "<Plug>TreeSelect", { buffer = args.buf, })
--     vim.keymap.set("n", "<C-f>", "<Plug>TreeCloseTree", { buffer = args.buf, })
--     vim.keymap.set("n", "<", "<Plug>TreeDecreaseLevel", { buffer = args.buf, })
--     vim.keymap.set("n", ">", "<Plug>TreeIncreaseLevel", { buffer = args.buf, })
--     vim.keymap.set("n", "h", "<Plug>TreeOutDir", { buffer = args.buf, })
--     vim.keymap.set("n", "l", "<Plug>TreeInDir", { buffer = args.buf, })
--     vim.keymap.set("n", "yr", "<Plug>TreeYankRelativePath", { buffer = args.buf, })
--     vim.keymap.set("n", "ya", "<Plug>TreeYankAbsolutePath", { buffer = args.buf, })
--     vim.keymap.set("n", "o", "<Plug>TreeCreate", { buffer = args.buf, })
--     vim.keymap.set("n", "e", "<Plug>TreeRefresh", { buffer = args.buf, })
--     vim.keymap.set("n", "r", "<Plug>TreeRename", { buffer = args.buf, })
--     vim.keymap.set("n", "dd", "<Plug>TreeDelete", { buffer = args.buf, })
--
--     vim.keymap.set("v", "d", "<Plug>TreeDelete", { buffer = args.buf, })
--   end,
-- })

vim.g.netrw_banner = 0
vim.g.netrw_altfile = 1
vim.g.netrw_keepdir = 0
vim.g.netrw_localcopydircmd = "cp -r"
vim.g.netrw_preview = 0
vim.g.netrw_alto = 0

vim.keymap.set("n", "<C-f>", function()
  local bufname = vim.api.nvim_buf_get_name(0)
  local dirname = vim.fs.dirname(bufname)
  vim.cmd.Explore(dirname)
  if vim.api.nvim_get_current_line() == "../" then
    vim.cmd.normal "gh"
  end
end, { desc = "Toggle netrw, focusing the current buffer", })

vim.api.nvim_create_autocmd("BufModifiedSet", {
  callback = function()
    if not (vim.bo and vim.bo.filetype == "netrw") then
      return
    end

    vim.opt_local.relativenumber = true

    vim.keymap.set("n", "h", "-", { buffer = true, remap = true, })
    vim.keymap.set("n", "l", function()
      local line = vim.api.nvim_get_current_line()
      if vim.endswith(line, "/") then
        return "<cr>"
      end
    end, { expr = true, buffer = true, remap = true, })

    vim.keymap.set("n", "o", "%<cmd>write<cr>", { buffer = true, remap = true, })
    vim.keymap.set("n", "r", "R", { buffer = true, remap = true, })
    vim.keymap.set("n", "P", "<C-w>z", { buffer = true, remap = true, })
    vim.keymap.set("n", "<C-f>", vim.cmd.bdelete, { buffer = true, })
  end,
  group = vim.api.nvim_create_augroup("netrw", { clear = false, }),
})
