vim.keymap.set("i", "<C-p>", "<C-o>:Snippet<space>", { desc = "Insert a snippet", })
vim.keymap.set("n", "<leader>h", ":help<space>", { desc = ":help", })

vim.keymap.set("n", "<leader>q", vim.cmd.quit, { desc = "Quit", })
vim.keymap.set("n", "J", "gJ", { desc = "J without whitespace", })
vim.keymap.set("n", "<leader>c", vim.cmd.copen, { desc = ":copen", })
vim.keymap.set("n", "/", "/\\V", { desc = "/ without regex", })
vim.keymap.set("n", "<leader>/c", "/\\C<left><left>", { desc = "/ case sensitive", })
vim.keymap.set("n", "<leader>/w", "/\\<\\><left><left>", { desc = "/ word sensitive", })
vim.keymap.set("n", "<leader>/e", "/\\<\\>\\C<left><left><left><left>", { desc = "/ case and word sensitive", })
vim.keymap.set("n", "<leader>/s", ":%s/\\<\\>\\C/<left><left><left><left><left>",
  { desc = "%s in the current buffer, case and word sensitive", })
vim.keymap.set("n", "<leader>n", vim.cmd.nohlsearch, { desc = "Turn off highlighting", })
vim.keymap.set("n", "<leader>x", vim.cmd.tabclose, { desc = "Close the current tab", })
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
vim.keymap.set("n", "<leader>P", function() vim.cmd.pu { bang = true, } end, { desc = "Put on the line above", })
vim.keymap.set("n", "<leader>p", vim.cmd.pu, { desc = "Put on the line below", })
vim.keymap.set("n", "<leader>e", vim.cmd.edit)
vim.keymap.set("n", "j", function()
  if vim.v.count > 0 then return "j" end
  return "gj"
end, { desc = "j with display lines", expr = true, })
vim.keymap.set("n", "k", function()
  if vim.v.count > 0 then return "k" end
  return "gk"
end, { desc = "k with display lines", expr = true, })
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

vim.keymap.set("n", "<leader>ur", function() require "helpers".utils.set_and_rotate(vim.fn.getreg "r") end)
vim.keymap.set("n", "<leader>ua", function() require "helpers".utils.set_and_rotate(vim.fn.getreg "a") end)
vim.keymap.set("n", "<leader>ud", function() require "helpers".utils.set_and_rotate(vim.fn.getreg "d") end)
vim.keymap.set("n", "<leader>ub", function() require "helpers".utils.set_and_rotate(vim.fn.getreg "b") end)

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
  require "helpers".utils.set_and_rotate(abs_path)
end, { desc = "Yank the absolute path of the current buffer", })

vim.keymap.set("n", "<leader>yr", function()
  local rel_path = assert(vim.fs.relpath(vim.fn.getcwd(), vim.api.nvim_buf_get_name(0)))
  require "helpers".utils.set_and_rotate(rel_path)
end, { desc = "Yank the relative path of the current buffer", })

vim.keymap.set("n", "<leader>yf", function()
  vim.fn.setqflist(vim.fn.getqflist())
  require "helpers".notify.doing "Duplicated the current quickfix list"
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
  require "helpers".notify.doing "common fold commands: z{t,T,c,C,o,O,R(open all folds),M(close all folds)}"
end, { desc = "Toggle fold", })
vim.keymap.set("n", "ze", "z=", { desc = "z=", })

vim.keymap.set("n", "q", function()
  if vim.fn.reg_recording() == "" then
    return "qq"
  elseif vim.fn.reg_recording() == "q" then
    return "q"
  end
end, { expr = true, nowait = true, desc = "Record a macro", })
vim.keymap.set("n", "<leader>v", "G" .. "V" .. "gg", { desc = "Select the entire buffer", })
vim.keymap.set("n", "*", function()
  vim.fn.setreg("/", ("\\<%s\\>\\C"):format(vim.fn.expand "<cword>"))
  vim.o.hlsearch = true
end, { silent = true, desc = "* but stay on the current search result", })

-- https://yobibyte.github.io/vim.html
vim.keymap.set("n", "<leader>'", function()
  vim.ui.input({ prompt = "$ ", }, function(cmd)
    if cmd and cmd ~= "" then
      vim.cmd.vnew()
      vim.bo.buftype = "nofile"
      vim.bo.bufhidden = "wipe"
      vim.bo.buflisted = false
      vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.fn.systemlist(cmd))
    end
  end)
end, { desc = "Execute a terminal command and output the result to a buffer", })

vim.keymap.set("c", "<C-e>", "<C-e><C-z>", { desc = "<C-e> and retrigger wildtrigger", })
vim.keymap.set("c", "<Left>", function()
  if vim.fn.wildmenumode() == require "helpers".vimscript_true then
    return "<C-e><Left><C-z>"
  end
  return "<Left>"
end, { expr = true, desc = "<Left> and retrigger wildtrigger", })
vim.keymap.set("c", "<Right>", function()
  if vim.fn.wildmenumode() == require "helpers".vimscript_true then
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

vim.keymap.set("n", "<leader>k", function()
  return "k" .. [["zyy]] .. vim.v.count .. "j" .. [["zp]]
end, { desc = "Yank the file vim.v.count above and put it on the current line", expr = true, })
vim.keymap.set("n", "<leader>j", function()
  return "j" .. [["zyy]] .. vim.v.count .. "k" .. [["zp]]
end, { desc = "Yank the file vim.v.count below and put it on the current line", expr = true, })

vim.keymap.set("n", "<C-j>", "<C-]>", { desc = "<C-]>", })
vim.keymap.set("n", "<C-k>", "<C-w><C-]>", { desc = "<C-w><C-]>", })

vim.keymap.set("n", "<leader>t",
  function()
    vim.cmd.source()
    require "helpers".notify.doing(":source " .. vim.api.nvim_buf_get_name(0))
  end, { desc = ":source", })

vim.keymap.set("n", "<leader>w", function()
  local winnr = vim.api.nvim_open_win(0, false, { split = "below", win = 0, })
  vim.api.nvim_win_set_height(0, 1)
  vim.api.nvim_set_current_win(winnr)
  require "helpers".notify.doing "Duplicated buf and split win"
end)

vim.keymap.set("n", "<leader>mD", function()
  vim.cmd.delmarks "A-Za-z"
  pcall(require "marks".refresh_signs)
  require "helpers".notify.doing "Deleted all marks"
end)
vim.keymap.set({ "i", "c", }, "<C-r><C-;>", "<C-r>+")
vim.keymap.set({ "i", "c", }, "<C-r>;", "<C-r>+")
vim.keymap.set({ "i", "c", }, "<C-h>", "<left>")
vim.keymap.set({ "i", "c", }, "<C-l>", "<right>")
vim.keymap.set("i", "<C-j>", "<down>")
vim.keymap.set("i", "<C-k>", "<up>")
vim.keymap.set({ "i", "c", }, "<C-w>", "<C-o>w")
vim.keymap.set({ "i", "c", }, "<C-b>", "<C-o>b")
vim.keymap.set({ "i", "c", }, "<C-a>", "<C-o>0")
vim.keymap.set({ "i", "c", }, "<C-e>", "<C-o>$")

vim.keymap.set("i", "<C-g>", function()
  local row_1i, col_0i = unpack(vim.api.nvim_win_get_cursor(0))
  local row_0i = row_1i - 1
  local col_1i = col_0i + 1
  local line = vim.api.nvim_get_current_line()

  local col_1i_excl = col_1i - 1
  -- \- makes it non-greedy
  -- () is a capture group, returns what's inside
  local tag_content = line:sub(1, col_1i_excl):match ".*<(.-)>.*$"
  if tag_content == nil then return require "helpers".notify.error "No matching tag" end

  -- match non-whitespace characters from the start
  local tag_name = tag_content:match "^%S+"
  if tag_name == nil then return require "helpers".notify.error "Invalid tag name" end

  local closing_tag = "</" .. tag_name .. ">"
  vim.api.nvim_buf_set_lines(0, row_0i, row_0i + 1, true, {
    line:sub(1, col_1i_excl) .. closing_tag .. line:sub(col_1i),
  })
end, { desc = "Close the html tag to left of the cursor", })

-- abcdefghijklmnopqrstuvwxyz
-- ------------m--------v---z used by the os
-- a--d--g-i-----o--r--u-w--- used in normal mode
-- -bc-ef-h-jkl-n-pq-st---xy- available in normal

-- ab--e--h-jkl------s---w-y- used in insert mode
-- --cd-fg-i----nopqr-tu--x-- available in insert

-- --c--f-------n-pq--t---x-- available in both

-- normal mode actions:
-- (both)
-- toggle virtual lines (t)
-- close floating popup (c)

-- (only normal)
-- toggle file tree (f)
-- jump to tag (j)
-- jump to tag in a split (k)
-- next qf item (n)
-- prev qf item (p)

-- insert mode actions:
-- (both)
-- toggle virtual lines (t)
-- close floating popup (c)

-- (only insert)
-- trigger snippet (p)
-- trigger html closing tag ()
