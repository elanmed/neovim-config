local h = require "helpers"

vim.keymap.set("i", "<C-t>", "<C-o>:Snippet<space>")
vim.keymap.set({ "n", "v", }, "<C-t>", function()
  h.notify.error "snippets only supported in insert mode!"
end)
vim.keymap.set("n", "q:", function()
  h.notify.error "Use :q to quit or q? to open the command-line window instead!"
end, { desc = "Prevent accidentally opening the command-line window", })

vim.keymap.set("n", "G", function() return "G" .. "zz" end, { expr = true, })
vim.keymap.set("n", "<bs>", function()
  if vim.bo.readonly then
    h.notify.error "Buffer is readonly, aborting"
    return
  end
  vim.cmd "w"
end, { desc = "Save", })
vim.keymap.set("n", "<leader>q", h.keys.vim_cmd_cb "q", { desc = "Quit", })
vim.keymap.set("v", "<", "<gv", { desc = "Outdent, while keeping selection", })
vim.keymap.set("v", ">", ">gv", { desc = "Indent, while keeping selection", })
vim.keymap.set("n", "J", "gJ", { desc = "J without whitespace", })
vim.keymap.set("n", "<leader>co", h.keys.vim_cmd_cb "copen")
vim.keymap.set("n", "<leader>cc", function()
  vim.cmd "pclose"
  vim.cmd "cclose"
end)
-- https://vim.fandom.com/wiki/Moving_lines_up_or_down
vim.keymap.set("n", "<A-j>", ":m .+1<cr>==", { desc = "Move line down", })
vim.keymap.set("n", "<A-k>", ":m .-2<cr>==", { desc = "Move line up", })
vim.keymap.set("i", "<A-j>", "<esc>:m .+1<cr>==gi", { desc = "Move line down", })
vim.keymap.set("i", "<A-k>", "<esc>:m .-2<cr>==gi", { desc = "Move line up", })
vim.keymap.set("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move line down", })
vim.keymap.set("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move line up", })
vim.keymap.set("n", "<leader>/c", "/\\C<left><left>", { desc = "/ case sensitive", })
vim.keymap.set("n", "<leader>/w", "/\\<\\><left><left>", { desc = "/ word sensitive", })
vim.keymap.set("n", "<leader>f", "/\\<\\>\\C<left><left><left><left>", { desc = "/ case and word sensitive", })
vim.keymap.set("n", "<leader>/s", ":%s/\\<\\>\\C/<left><left><left><left><left>",
  { desc = "Search and replace in the current buffer, case and word sensitive", })
vim.keymap.set("n", "<leader>n", h.keys.vim_cmd_cb "nohlsearch", { desc = "Turn off highlighting", })
vim.keymap.set("n", "<leader>/v", "/\\V", { desc = "/ without regex", })
vim.keymap.set("n", "x", [["_x]])
vim.keymap.set("n", "X", [["_X]])
vim.keymap.set("n", "c", [["_c]])
vim.keymap.set("n", "C", [["_C]])
vim.keymap.set("n", "<leader>x", h.keys.vim_cmd_cb "tabclose", { desc = "Close the current tab", })
vim.keymap.set("n", "<leader>d", h.keys.vim_cmd_cb "silent! bdelete!", { desc = "Close the current buffer", })
vim.keymap.set("n", "<leader>;", ":")
vim.keymap.set("n", "<leader>'", [["]])
vim.keymap.set("n", "<leader>e", h.keys.vim_cmd_cb "e")
vim.keymap.set("n", "j", "gj", { desc = "j with display lines", })
vim.keymap.set("n", "k", "gk", { desc = "k with display lines", })
vim.keymap.set("n", "$", "g$", { desc = "k with display lines", })
vim.keymap.set("n", "0", "g0", { desc = "k with display lines", })
vim.keymap.set("i", "<C-e>", "<C-o>g$")
vim.keymap.set({ "n", "v", }, "<C-e>", "g$")
vim.keymap.set("i", "<C-a>", "<C-o>g^")
vim.keymap.set({ "n", "v", }, "<C-a>", "g^")
vim.keymap.set("n", "<leader>pr", function()
  local select_inner_word = "viw"
  local empty_register = [["_]]
  local delete = "d"
  local paste_before_cursor = "P"
  return select_inner_word .. empty_register .. delete .. paste_before_cursor
end, { expr = true, desc = "Paste without overwriting the default register", })
vim.keymap.set("v", "<leader>pr", function()
  local empty_register = [["_]]
  local delete = "d"
  local paste_before_cursor = "P"
  return empty_register .. delete .. paste_before_cursor
end, { expr = true, desc = "Paste without overwriting the default register", })
vim.keymap.set("n", "<leader>pj", h.keys.vim_cmd_cb "pu", { desc = "Paste on the line below", })
vim.keymap.set("n", "<leader>pk", h.keys.vim_cmd_cb "pu!", { desc = "Paste on the line above", })
vim.keymap.set("i", "<C-_>", "<C-o>gcc", { remap = true, })
vim.keymap.set("n", "<C-_>", "gcc", { remap = true, })
vim.keymap.set("v", "<C-_>",
  function()
    local comment = "gc"
    local reselect_last = "gv"
    return comment .. reselect_last
  end, { expr = true, remap = true, })

vim.keymap.set("n", "<leader>yp", function()
  local yank_line = [["zyy]]
  local paste_line = [["zp]]
  return yank_line .. paste_line
end, { expr = true, desc = "Copy and paste the current line", })

vim.keymap.set("v", "<leader>yp", function()
  local yank_and_unselect = [["zy]]
  local move_to_end_selection = "`>"
  local paste_line = [["zp]]
  return yank_and_unselect .. move_to_end_selection .. paste_line .. move_to_end_selection
end, { expr = true, desc = "Copy and paste the current selection", })

vim.keymap.set("n", "<leader>yc",
  function()
    local yank_line = [["zyy]]
    local comment_line = "gcc"
    local paste_line = [["zp]]
    return yank_line .. comment_line .. paste_line
  end,
  { expr = true, remap = true, desc = "Yank the current line, comment it, and paste it below", })

vim.keymap.set("v", "<leader>yc",
  function()
    local yank_and_unselect = [["zy]]
    local move_to_end_selection = "`>"
    local paste_selection = [["zp]]
    local reselect_last = "gv"
    local comment_selection = "gc"
    return yank_and_unselect ..
        reselect_last ..
        comment_selection ..
        move_to_end_selection ..
        paste_selection ..
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
  local cur_buf = vim.api.nvim_get_current_buf()

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf == cur_buf then
      goto continue
    end
    if vim.api.nvim_get_option_value("modified", { buf = buf, }) then
      goto continue
    end
    vim.api.nvim_buf_delete(buf, { force = true, })

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

vim.keymap.set("n", "<leader>w", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<leader>z", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<leader>,", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<leader>.", "<nop>", { desc = "TODO find a remap", })
