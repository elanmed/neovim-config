local h = require "helpers"

vim.keymap.set("i", "<C-t>", "<C-o>:Snippet<space>", { desc = "Insert a snippet", })
vim.keymap.set({ "n", "v", }, "<C-t>", function()
  h.notify.error "Snippets only supported in insert mode!"
end, { desc = "Insert a snippet", })
vim.keymap.set("n", "<leader>h", ":help<space>", { desc = ":help", })

vim.keymap.set("n", "<bs>", function()
  if vim.bo.readonly then
    h.notify.error "Buffer is readonly, aborting"
    return
  end
  if vim.bo.buftype ~= "" then
    h.notify.error "`buftype` is set, aborting"
    return
  end
  vim.cmd "write"
end, { desc = "Write", })
vim.keymap.set("n", "<leader>w", function()
  if vim.bo.readonly then
    h.notify.error "Buffer is readonly, aborting"
    return
  end
  if vim.bo.buftype ~= "" then
    h.notify.error "`buftype` is set, aborting"
    return
  end

  local view = vim.fn.winsaveview()
  vim.cmd "normal! gg=G"
  vim.fn.winrestview(view)
  vim.cmd "write"
end, { desc = "Write", })
vim.keymap.set("n", "<leader>q", h.keys.vim_cmd_cb "quit", { desc = "Quit", })
vim.keymap.set("n", "J", "gJ", { desc = "J without whitespace", })
vim.keymap.set("n", "<leader>c", h.keys.vim_cmd_cb "copen", { desc = ":copen", })
vim.keymap.set("n", "/", "/\\V", { desc = "/ without regex", })
vim.keymap.set("n", "<leader>/c", "/\\C<left><left>", { desc = "/ case sensitive", })
vim.keymap.set("n", "<leader>/w", "/\\<\\><left><left>", { desc = "/ word sensitive", })
vim.keymap.set("n", "<leader>/e", "/\\<\\>\\C<left><left><left><left>", { desc = "/ case and word sensitive", })
vim.keymap.set("n", "<leader>/s", ":%s/\\<\\>\\C/<left><left><left><left><left>",
  { desc = "%s in the current buffer, case and word sensitive", })
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
vim.keymap.set("n", "<leader>;", ":", { desc = ":", })
vim.keymap.set("n", "x", [["_x]], { desc = "x to the black hole buffer", })
vim.keymap.set("n", "X", [["_X]], { desc = "X to the black hole buffer", })
vim.keymap.set("n", "c", [["_c]], { desc = "c to the black hole buffer", })
vim.keymap.set("n", "C", [["_C]], { desc = "C to the black hole buffer", })
vim.keymap.set("n", "<leader>p", h.keys.vim_cmd_cb "pu", { desc = "Put on the line below", })
vim.keymap.set("n", "<leader>P", h.keys.vim_cmd_cb "pu!", { desc = "Put on the line above", })
vim.keymap.set("n", "<leader>e", h.keys.vim_cmd_cb "e")
vim.keymap.set("n", "j", "gj", { desc = "j with display lines", })
vim.keymap.set("n", "k", "gk", { desc = "k with display lines", })
vim.keymap.set("n", "$", "g$", { desc = "$ with display lines", })
vim.keymap.set("n", "0", "g0", { desc = "0 with display lines", })
vim.keymap.set("i", "<C-/>", "<C-o>gcc", { remap = true, desc = "Comment the current line", })
vim.keymap.set("n", "<C-/>", "gcc", { remap = true, desc = "Comment the current line", })
vim.keymap.set("v", "<C-/>",
  function()
    local comment = "gc"
    local reselect_last = "gv"
    return comment .. reselect_last
  end, { expr = true, remap = true, desc = "Comment the visual selection", })

vim.keymap.set("n", "<leader>yc",
  function()
    local z_register = [["z]]
    local yank_line = "yy"
    local comment_line = "gcc"
    local put = "p"
    return z_register .. yank_line .. comment_line .. z_register .. put
  end,
  { expr = true, remap = true, desc = "Yank the current line, comment it, and put it below", })

vim.keymap.set("v", "<leader>yc",
  function()
    local z_register = [["z]]
    local yank_and_unselect = "y"
    local move_to_end_selection = "`>"
    local put = "p"
    local reselect_last = "gv"
    local comment_selection = "gc"
    return
        z_register ..
        yank_and_unselect ..
        reselect_last ..
        comment_selection ..
        move_to_end_selection ..
        z_register ..
        put
  end, { expr = true, remap = true, desc = "Yank the current selection, comment, and put it below", })

vim.keymap.set("v", "<leader>yp", function()
  local z_register = [["z]]
  local yank_and_unselect = "y"
  local move_to_end_selection = "`>"
  local put = "p"
  return z_register .. yank_and_unselect .. move_to_end_selection .. z_register .. put
end, { expr = true, desc = "Yank and put the visual selection", })

vim.keymap.set("n", "<leader>ya", function()
  local abs_path = vim.api.nvim_buf_get_name(0)
  vim.fn.setreg("+", abs_path)
  h.notify.doing("yanked: " .. abs_path)
end, { desc = "Yank the absolute path of the current buffer", })

vim.keymap.set("n", "<leader>yr", function()
  local rel_path = vim.fs.relpath(vim.fn.getcwd(), vim.api.nvim_buf_get_name(0))
  vim.fn.setreg("+", rel_path)
  h.notify.doing("yanked: " .. rel_path)
end, { desc = "Yank the relative path of the current buffer", })

vim.keymap.set("n", "<leader>yf", function()
  vim.fn.setqflist(vim.fn.getqflist())
  h.notify.doing "Created a new list!"
end, { desc = "Duplicate the current quickfix list", })

-- https://stackoverflow.com/a/9407015
local function next_closed_fold(direction)
  local view = vim.fn.winsaveview()
  local prev_line_num = 0
  local curr_line_num = view.lnum
  local is_open = true

  while curr_line_num ~= prev_line_num and is_open do
    vim.cmd("normal! z" .. direction)
    prev_line_num = curr_line_num
    curr_line_num = vim.fn.line "."
    is_open = vim.fn.foldclosed(curr_line_num) < 0
  end

  if is_open then
    vim.fn.winrestview(view)
  end
end

vim.keymap.set("n", "zj", function() next_closed_fold "j" end, { desc = "Navigate to the next closed fold", })
vim.keymap.set("n", "zk", function() next_closed_fold "k" end, { desc = "Navigate to the prev closed fold", })
vim.keymap.set("n", "zt", "za", { desc = "Toggle fold", })
vim.keymap.set("n", "zT", "zA", { desc = "Toggle fold", })
vim.keymap.set("n", "z?", function()
  h.notify.doing "common fold commands: z{t,T,c,C,o,O,R(open all folds),M(close all folds)}"
end, { desc = "Toggle fold", })

vim.keymap.set("n", "q", function()
  if vim.fn.reg_recording() == "" then
    return "qq"
  elseif vim.fn.reg_recording() == "q" then
    return "q"
  end
end, { expr = true, nowait = true, desc = "Record a macro", })
vim.keymap.set("n", "<leader>V", "G" .. "V" .. "gg", { desc = "Select the entire buffer", })
vim.keymap.set("n", "*", function()
  local word = vim.fn.expand "<cword>"
  -- https://superuser.com/a/299693
  vim.cmd([[let @/ = '\<]] .. word .. [[\>']])
  vim.api.nvim_set_option_value("hlsearch", true, {})
  vim.o.hlsearch = true
end, { silent = true, desc = "* but stay on the current search result", })

-- https://yobibyte.github.io/vim.html
vim.keymap.set("n", "<leader>'", function()
  vim.ui.input({ prompt = "$ ", }, function(cmd)
    if cmd and cmd ~= "" then
      vim.cmd "vnew"
      vim.bo.buftype = "nofile"
      vim.bo.bufhidden = "wipe"
      vim.bo.buflisted = false
      vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.fn.systemlist(cmd))
    end
  end)
end, { desc = "Execute a terminal command and output the result to a buffer", })

vim.keymap.set("n", "<leader>g", function()
  local editor_height = vim.api.nvim_win_get_height(0)
  local border_height = 2

  local term_bufnr = vim.api.nvim_create_buf(false, true)
  local term_winnr = vim.api.nvim_open_win(term_bufnr, true, {
    relative = "editor",
    row = editor_height,
    col = 0,
    width = vim.o.columns,
    height = editor_height - border_height,
    border = "rounded",
    title = "Lazygit term",
  })
  vim.fn.jobstart("lazygit", {
    term = true,
    on_exit = function()
      vim.api.nvim_win_close(term_winnr, true)
    end,
  })
  vim.cmd "startinsert"
end, { desc = "Open lazygit", })

vim.keymap.set("n", "<leader>,", h.keys.vim_cmd_cb "file", { desc = "Show the current file", })

vim.keymap.set("c", "<C-e>", "<C-e><C-z>", { desc = "<C-e> and retrigger wildtrigger", })
vim.keymap.set("c", "<Left>", function()
  if vim.fn.wildmenumode() == h.vimscript_true then
    return "<C-e><Left><C-z>"
  end
  return "<Left>"
end, { expr = true, desc = "<Left> and retrigger wildtrigger", })
vim.keymap.set("c", "<Right>", function()
  if vim.fn.wildmenumode() == h.vimscript_true then
    return "<C-e><Right><C-z>"
  end
  return "<Right>"
end, { expr = true, desc = "<Right> and retrigger wildtrigger", })

-- https://vim.fandom.com/wiki/Moving_lines_up_or_down
vim.keymap.set("n", "<A-j>", [[:m .+1<CR>==]])
vim.keymap.set("n", "<A-k>", [[:m .-2<CR>==]])
vim.keymap.set("i", "<A-j>", [[<Esc>:m .+1<CR>==gi]])
vim.keymap.set("i", "<A-k>", [[<Esc>:m .-2<CR>==gi]])
vim.keymap.set("v", "<A-j>", [[:m '>+1<CR>gv=gv]])
vim.keymap.set("v", "<A-k>", [[:m '<-2<CR>gv=gv]])
vim.keymap.set("v", ">", ">gv", { desc = "indent, preserving the selecting", })
vim.keymap.set("v", "<", "<gv", { desc = "outdent, preserving the selecting", })

vim.keymap.set("n", "H", "{", { desc = "{", })
vim.keymap.set("n", "L", "}", { desc = "}", })

vim.keymap.set("n", "<C-e>", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<C-i>", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<C-j>", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<C-x>", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<C-y>", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<leader>j", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<leader>k", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<leader>l", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<leader>u", "<nop>", { desc = "TODO find a remap", })
