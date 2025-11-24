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

local mini_icons = require "mini.icons"
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
    if vim.bo.filetype ~= "netrw" then return end

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

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local ns_id = vim.api.nvim_create_namespace "netrw"

    for idx_1i, line in ipairs(lines) do
      local idx_0i = idx_1i - 1
      if line == "../" or line == "./" then goto continue end

      local icon, hl_group = mini_icons.get(
        vim.endswith(line, "/") and "directory" or "file",
        line
      )

      vim.api.nvim_buf_set_extmark(0, ns_id, idx_0i, 0, {
        id = idx_1i,
        virt_text = { { icon, hl_group, }, { " ", "", }, },
        virt_text_pos = "inline",
      })

      ::continue::
    end
  end,
  group = vim.api.nvim_create_augroup("netrw", { clear = false, }),
})
