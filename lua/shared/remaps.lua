local h = require "shared.helpers"

-- delay when using vim.keymap.set
vim.cmd "inoremap <C-t> <C-o>:Snippet<space>"
vim.keymap.set({ "n", "v", }, "<C-t>", function() h.notify.error "snippets only supported in insert mode!" end)
vim.keymap.set("n", "q:",
  function()
    h.notify.warn "Use :q to quit or q? to open the command-line window instead!"
  end
  , { desc = "Prevent accidentally opening the command-line window", })

vim.keymap.set({ "n", "v", }, "b", "<Plug>(MatchitNormalForward)") -- TODO: what is this?
vim.keymap.set({ "n", "v", }, "<bs>", "b")
vim.keymap.set({ "n", }, "<leader>e", h.keys.vim_cmd_cb "e")

vim.keymap.set("n", "<leader>f", "<C-w>w", { desc = "Toggle focus between windows", })

vim.keymap.set({ "i", }, "<C-e>", "<C-o>$")
vim.keymap.set({ "n", "v", }, "<C-e>", "$")
vim.keymap.set({ "i", }, "<C-a>", "<C-o>^")
vim.keymap.set({ "n", "v", }, "<C-a>", "^")

vim.keymap.set("n", "<leader>o", "o<esc>")
vim.keymap.set("n", "<leader>O", "O<esc>")

vim.keymap.set("n", "E", [[viw"_dP]], { desc = "pastE without overwriting the default register", }) -- TODO: find a better remap
vim.keymap.set("n", "<leader>p", h.keys.vim_cmd_cb "pu", { desc = "Paste on the line below", })
vim.keymap.set("n", "<leader>P", h.keys.vim_cmd_cb "pu!", { desc = "Paste on the line above", })

vim.keymap.set("n", "<leader>yp", [["zyy"zp]], { desc = "Copy and paste the current line", })
vim.keymap.set({ "v", }, "<leader>yp", [["zy`>"zp]], { desc = "Copy and paste the current line", }) -- move to end of selection, then yank

vim.keymap.set("n", ",", h.keys.vim_cmd_cb "w", { desc = "Save", })
vim.keymap.set("n", "<leader>w", function() h.notify.error "Use , instead!" end, { desc = "Save", })
vim.keymap.set("n", "<leader>q", h.keys.vim_cmd_cb "q", { desc = "Save", })

vim.keymap.set("n", "<leader>ya", function() vim.fn.setreg("+", vim.fn.expand "%:p") end,
  { desc = "Yank the Absolute path of the current buffer", })
vim.keymap.set("n", "<leader>yr", function() vim.fn.setreg("+", vim.fn.expand "%:~:.") end,
  { desc = "Yank the Relative path of the current buffer", })

vim.keymap.set({ "v", }, "<", "<gv", { desc = "Outdent, while keeping selection", })
vim.keymap.set({ "v", }, ">", ">gv", { desc = "Indent, while keeping selection", })

--- @param try string
--- @param catch string
local function generate_circular_next_prev(try, catch)
  local success, _ = pcall(vim.cmd, try)
  if not success then
    pcall(vim.cmd, catch)
  end
end

vim.api.nvim_create_user_command("Cnext", function() generate_circular_next_prev("cnext", "cfirst") end, {})
vim.api.nvim_create_user_command("Cprev", function() generate_circular_next_prev("cprev", "clast") end, {})

vim.keymap.set("n", "J", h.keys.vim_cmd_cb "Cnext", { desc = "Move to the next item in the quickfix list", })
vim.keymap.set("n", "K", h.keys.vim_cmd_cb "Cprev", { desc = "Move to the prev item in the quickfix list", })
vim.keymap.set("n", "Z", "gJ", { desc = "J without whitespace", })

vim.keymap.set("n", "ge", h.keys.vim_cmd_cb "copen", { desc = "Open the quickfix list", })
vim.keymap.set("n", "gq", h.keys.vim_cmd_cb "cclose", { desc = "Close the quickfix list", })

vim.keymap.set("n", "gn", "gt", { desc = "Go to the next tab", })
vim.keymap.set("n", "gp", "gT", { desc = "Go to the prev tab", })

-- https://vim.fandom.com/wiki/Moving_lines_up_or_down
vim.keymap.set("n", "<A-j>", ":m .+1<cr>==", { desc = "Move line down", })
vim.keymap.set("n", "<A-k>", ":m .-2<cr>==", { desc = "Move line up", })
vim.keymap.set("i", "<A-j>", "<esc>:m .+1<cr>==gi", { desc = "Move line down", })
vim.keymap.set("i", "<A-k>", "<esc>:m .-2<cr>==gi", { desc = "Move line up", })
vim.keymap.set("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move line down", })
vim.keymap.set("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move line up", })

-- search Case sensitive, Whole word, and All
vim.cmd [[
  nnoremap <leader>/c /\C<left><left>
  nnoremap <leader>/w /\<\><left><left>
  nnoremap <leader>/a /\<\>\C<left><left><left><left>
]]
-- search without regex
vim.cmd [[
  nnoremap / /\V
]]
-- search and replace, case sensitive and by whole word
vim.cmd [[
  nnoremap <leader>/s :%s/\<\>\C/<left><left><left><left><left>
]]
vim.keymap.set("n", "<leader>/g", h.keys.vim_cmd_cb "nohlsearch", { desc = "Turn off hiGhlighting", })

vim.keymap.set({ "n", "v", }, "n", "nzz")
vim.keymap.set({ "n", "v", }, "N", "Nzz")

-- prevent x, c from overwriting the clipboard
vim.keymap.set("n", "x", [["_x]])
vim.keymap.set("n", "X", [["_X]])
vim.keymap.set("n", "c", [["_c]])
vim.keymap.set("n", "C", [["_C]])

local function count_based_keymap(movement)
  local count = vim.v.count
  if count > 0 then
    return movement
  else
    return "g" .. movement
  end
end

vim.keymap.set("n", "j", function() return count_based_keymap "j" end,
  { expr = true, desc = "j, but respect lines that wrap", })
vim.keymap.set("n", "k", function() return count_based_keymap "k" end,
  { expr = true, desc = "k, but respect lines that wrap", })

vim.keymap.set({ "n", "v", "i", }, "<C-y>", h.keys.vim_cmd_cb "tabclose", { desc = "Close the current tab", })
vim.keymap.set("n", "Y", h.keys.vim_cmd_cb "silent! bdelete!", { desc = "Close the current buffer", })
vim.keymap.set("n", "<leader>ua", h.keys.vim_cmd_cb "silent! bufdo bdelete", { desc = "Close all buffers", })
vim.keymap.set("n", "<leader>uo", function()
  local cur_buf = vim.api.nvim_get_current_buf()

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf == cur_buf then
      goto continue
    elseif vim.api.nvim_get_option_value("modified", { buf = buf, }) then
      goto continue
    else
      vim.api.nvim_buf_delete(buf, { force = true, })
    end

    ::continue::
  end
end)

vim.keymap.set({ "n", "v", "i", }, "<C-u>", function()
  if vim.fn.line "$" == vim.fn.line "." then
    return "M"
  else
    return "<C-u>"
  end
end, { expr = true, })

vim.keymap.set({ "n", "v", "i", }, "<C-d>", function()
  if vim.fn.line "." == 1 then
    return "M"
  else
    return "<C-d>"
  end
end, { expr = true, })

-- https://stackoverflow.com/a/9407015
local function next_closed_fold(dir)
  local view = vim.fn.winsaveview()
  local prev_line_num = 0
  local curr_line_num = view.lnum
  local is_open = true

  while curr_line_num ~= prev_line_num and is_open do
    h.keys.send_keys("n", "z" .. dir)
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
  h.notify.info "common fold commands: z{t,T,c,C,o,O,R(open all folds),M(close all folds)}"
end
, { desc = "Toggle fold", })

vim.keymap.set("n", "W", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "B", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<C-x>", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<C-g>", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<leader>;", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<leader>b", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<leader>c", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<leader>d", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<leader>g", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<leader>i", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<leader>j", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<leader>k", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<leader>m", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<leader>n", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<leader>v", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<leader>x", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<leader>z", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<leader>,", "<nop>", { desc = "TODO find a remap", })
vim.keymap.set("n", "<leader>.", "<nop>", { desc = "TODO find a remap", })
