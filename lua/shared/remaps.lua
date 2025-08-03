local h = require "helpers"

vim.keymap.set("n", "L", h.keys.vim_cmd_cb "bnext")
vim.keymap.set("n", "H", h.keys.vim_cmd_cb "bprev")
vim.keymap.set("i", "<C-t>", "<C-o>:Snippet<space>")
vim.keymap.set({ "n", "v", }, "<C-t>", function()
  h.notify.error "snippets only supported in insert mode!"
end)
vim.keymap.set("n", "q:", function()
  h.notify.error "Use :q to quit or q? to open the command-line window instead!"
end, { desc = "Prevent accidentally opening the command-line window", })

vim.keymap.set("n", "G", "G" .. "zz")
vim.keymap.set("n", "<bs>", function()
  if vim.bo.readonly then
    h.notify.error "Buffer is readonly, aborting"
    return
  end
  vim.cmd "write"
end, { desc = "Save", })
vim.keymap.set("n", "<leader>q", h.keys.vim_cmd_cb "quit", { desc = "Quit", })
vim.keymap.set("n", "J", "gJ", { desc = "J without whitespace", })
vim.keymap.set("n", "<leader>co", h.keys.vim_cmd_cb "copen")
vim.keymap.set("n", "<leader>cc", function()
  vim.cmd "pclose"
  vim.cmd "cclose"
end)
vim.keymap.set("n", "g/c", "/\\C<left><left>", { desc = "/ case sensitive", })
vim.keymap.set("n", "g/w", "/\\<\\><left><left>", { desc = "/ word sensitive", })
vim.keymap.set("n", "g//", "/\\<\\>\\C<left><left><left><left>", { desc = "/ case and word sensitive", })
vim.keymap.set("n", "g/v", "/\\V", { desc = "/ without regex", })
vim.keymap.set("n", "g/s", ":%s/\\<\\>\\C/<left><left><left><left><left>",
  { desc = "Search and replace in the current buffer, case and word sensitive", })
vim.keymap.set("n", "<leader>n", h.keys.vim_cmd_cb "nohlsearch", { desc = "Turn off highlighting", })
vim.keymap.set("n", "<leader>x", h.keys.vim_cmd_cb "tabclose", { desc = "Close the current tab", })
vim.keymap.set("n", "<leader>d", function()
  local mini_ok, mini_bufremove = pcall(require, "mini.bufremove")
  if mini_ok then
    mini_bufremove.delete(0)
  else
    vim.cmd "silent! bdelete!"
  end
end, { desc = "Close the current buffer", })
vim.keymap.set("n", "<leader>;", ":")
vim.keymap.set("n", "x", [["_x]])
vim.keymap.set("n", "X", [["_X]])
vim.keymap.set("n", "c", [["_c]])
vim.keymap.set("n", "C", [["_C]])
vim.keymap.set("n", "<leader>w", [["_]])
vim.keymap.set("n", "<leader>p", h.keys.vim_cmd_cb "pu", { desc = "Paste on the line below", })
vim.keymap.set("n", "<leader>P", h.keys.vim_cmd_cb "pu!", { desc = "Paste on the line above", })
vim.keymap.set("n", "<leader>e", h.keys.vim_cmd_cb "e")
vim.keymap.set("n", "j", "gj", { desc = "j with display lines", })
vim.keymap.set("n", "k", "gk", { desc = "k with display lines", })
vim.keymap.set("n", "$", "g$", { desc = "k with display lines", })
vim.keymap.set("n", "0", "g0", { desc = "k with display lines", })
vim.keymap.set("i", "<C-/>", "<C-o>gcc", { remap = true, })
vim.keymap.set("n", "<C-/>", "gcc", { remap = true, })
vim.keymap.set("v", "<C-/>",
  function()
    local comment = "gc"
    local reselect_last = "gv"
    return comment .. reselect_last
  end, { expr = true, remap = true, })

vim.keymap.set("n", "<leader>yc",
  function()
    local z_register = [["z]]
    local yank_line = "yy"
    local comment_line = "gcc"
    local paste_line = "p"
    return z_register .. yank_line .. comment_line .. z_register .. paste_line
  end,
  { expr = true, remap = true, desc = "Yank the current line, comment it, and paste it below", })

vim.keymap.set("v", "<leader>yc",
  function()
    local z_register = [["z]]
    local yank_and_unselect = "y"
    local move_to_end_selection = "`>"
    local paste = "p"
    local reselect_last = "gv"
    local comment_selection = "gc"
    return
        z_register ..
        yank_and_unselect ..
        reselect_last ..
        comment_selection ..
        move_to_end_selection ..
        z_register ..
        paste ..
        move_to_end_selection
  end, { expr = true, remap = true, desc = "Yank the current selection, comment it, and paste it below", })

vim.keymap.set("n", "<leader>ya", function()
  vim.fn.setreg("+", vim.fn.expand "%:p")
end, { desc = "Yank the Absolute path of the current buffer", })

vim.keymap.set("n", "<leader>yr",
  function()
    vim.fn.setreg("+", vim.fn.expand "%:~:.")
  end, { desc = "Yank the Relative path of the current buffer", })

vim.keymap.set("n", "<leader>yq",
  function()
    vim.fn.setqflist(vim.fn.getqflist())
    h.notify.doing "Created a new list!"
  end, { desc = "Duplicate the current quickfix list", })

vim.keymap.set("n", "<leader>ua", h.keys.vim_cmd_cb "silent! bufdo bdelete", { desc = "Close all buffers", })
vim.keymap.set("n", "<leader>uo", function()
  local mini_ok, mini_bufremove = pcall(require, "mini.bufremove")
  local cur_buf = vim.api.nvim_get_current_buf()

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf == cur_buf then
      goto continue
    end
    if vim.api.nvim_get_option_value("modified", { buf = buf, }) then
      goto continue
    end
    if mini_ok then
      mini_bufremove.delete(buf, true)
    else
      vim.api.nvim_buf_delete(buf, { force = true, })
    end

    ::continue::
  end
end)

-- https://stackoverflow.com/a/9407015
local function next_closed_fold(direction)
  local view = vim.fn.winsaveview()
  local prev_line_num = 0
  local curr_line_num = view.lnum
  local is_open = true

  while curr_line_num ~= prev_line_num and is_open do
    h.keys.send_keys("n", "z" .. direction)
    prev_line_num = curr_line_num
    curr_line_num = vim.fn.line "."
    is_open = vim.fn.foldclosed(curr_line_num) < 0
  end

  if is_open then
    vim.fn.winrestview(view)
  end
end

vim.keymap.set("n", "zj", function() next_closed_fold "j" end)
vim.keymap.set("n", "zk", function() next_closed_fold "k" end)
vim.keymap.set("n", "zt", "za", { desc = "Toggle fold", })
vim.keymap.set("n", "zT", "zA", { desc = "Toggle fold", })
vim.keymap.set("n", "z?", function()
  h.notify.doing "common fold commands: z{t,T,c,C,o,O,R(open all folds),M(close all folds)}"
end, { desc = "Toggle fold", })

vim.keymap.set("n", "q", "<nop>", { desc = "Avoid accidentally recording a macro", })
vim.keymap.set("n", "<leader>.r", function()
  if vim.fn.reg_recording() == "" then
    return "qq"
  elseif vim.fn.reg_recording() == "q" then
    return "q"
  end
end, { expr = true, desc = "Record a macro", })
vim.keymap.set("n", "<leader>.e", "@Q", { desc = "Execute a macro", })
vim.keymap.set("n", "<leader>V", "G" .. "V" .. "gg", { desc = "Execute a macro", })
vim.keymap.set("n", "*", function()
  local word = vim.fn.expand "<cword>"
  -- https://superuser.com/a/299693
  vim.cmd([[let @/ = '\<]] .. word .. [[\>']])
  vim.api.nvim_set_option_value("hlsearch", true, {})
end, { silent = true, desc = "*, but stay on the current search result", })
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "TODO find a remap", })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "TODO find a remap", })

vim.keymap.set("n", "<leader>j", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<leader>/", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<leader>'", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<leader>,", "<nop>", { desc = "TODO find a remap", })
