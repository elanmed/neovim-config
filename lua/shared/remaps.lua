local h = require "shared.helpers"

-- delay when using h.*map
vim.cmd "nnoremap ; :"
vim.cmd "vnoremap ; :"
-- vim.cmd "nnoremap <c-c> :Snippet<space>"
vim.cmd "inoremap <c-c> <c-o>:Snippet<space>"
h.nmap("<c-c>", function() print "snippets only supported in insert mode!" end)

vim.cmd [[
  nnoremap <leader>s :%s/\<\>\C/<left><left><left><left><left>
]]
h.nmap("<leader>af", "<C-6>", { desc = "Alternate file", })
h.nmap("<leader>va", "ggVG", { desc = "Select all", })
h.nmap("<bs>", "b")
h.nmap("*", "*N")
h.nmap("<leader>f", "<C-w>w", { desc = "Toggle focus between windows", })
h.nmap("<leader>e", h.user_cmd_cb "e", { desc = "Reload buffer", })
h.nmap("<leader>vs", h.user_cmd_cb "vsplit")

h.imap("<C-e>", "<C-o>$")
h.nmap("<C-e>", "$")
h.vmap("<C-e>", "$")
h.imap("<C-a>", "<C-o>0")
h.nmap("<C-a>", "0")
h.vmap("<C-a>", "0")

h.nmap("<leader>o", "o<esc>")
h.nmap("<leader>O", "O<esc>")

h.nmap("E", [[viw"_dP]], { desc = "pastE without overwriting the default register", }) -- TODO: find a better remap
h.nmap("<leader>p", h.user_cmd_cb "pu", { desc = "Paste on the line below", })
h.nmap("<leader>P", h.user_cmd_cb "pu!", { desc = "Paste on the line above", })

h.nmap("<leader>dl", [["zyy"zp]], { desc = "Duplicate the current line", })
h.vmap("<leader>dl", [["zy`>"zp]], { desc = "Duplicate the current line", }) -- move to end of selection, then yank

h.nmap("<leader>w", h.user_cmd_cb "w", { desc = "Save", })
h.nmap("<leader>q", h.user_cmd_cb "q", { desc = "Quit", })

h.nmap("<leader>ka", function() vim.fn.setreg("+", vim.fn.expand "%:p") end,
  { desc = "C(K)opy the absolute path of a file", })
h.nmap("<leader>kr", function() vim.fn.setreg("+", vim.fn.expand "%:~:.") end,
  { desc = "C(K)opy the relative path of a file", })

h.vmap("<", "<gv", { desc = "Outdent, while keeping selection", })
h.vmap(">", ">gv", { desc = "Indent, while keeping selection", })

local function gen_circular_next_prev(try, catch)
  local success, _ = pcall(vim.cmd, try)
  if not success then
    success, _ = pcall(vim.cmd, catch)
    if not success then
      return
    end
  end
end

vim.api.nvim_create_user_command("Cnext", function() gen_circular_next_prev("cnext", "cfirst") end, {})
vim.api.nvim_create_user_command("Cprev", function() gen_circular_next_prev("cprev", "clast") end, {})
vim.api.nvim_create_user_command("Lnext", function() gen_circular_next_prev("lnext", "lfirst") end, {})
vim.api.nvim_create_user_command("Lprev", function() gen_circular_next_prev("lprev", "llast") end, {})

h.nmap("Z", "gJ", { desc = "J without whitespace", })
h.nmap("J", function()
  vim.cmd "Cnext"
  h.send_normal_keys "zz"
end, { desc = "Move to the next item in the quickfix list", })
h.nmap("K", function()
  vim.cmd "Cprev"
  h.send_normal_keys "zz"
end, { desc = "Move to the previous item in the quickfix list", })
h.nmap("gn", "gt", { desc = "Go to the next tab", })
h.nmap("gp", "gT", { desc = "Go to the prev tab", })

h.nmap("ge", h.user_cmd_cb "copen 25", { desc = "Open the quickfix list", })
h.nmap("gq", h.user_cmd_cb "cclose", { desc = "Close the quickfix list", })

local alt_j = h.is_mac() and "∆" or "<A-j>"
local alt_k = h.is_mac() and "˚" or "<A-k>"

h.nmap(alt_j, ":m .+1<cr>==", { desc = "Move line down", })
h.nmap(alt_k, ":m .-2<cr>==", { desc = "Move line up", })
h.imap(alt_j, "<esc>:m .+1<cr>==gi", { desc = "Move line down", })
h.imap(alt_k, "<esc>:m .-2<cr>==gi", { desc = "Move line up", })
h.vmap(alt_j, ":m '>+1<cr>gv=gv", { desc = "Move line down", })
h.vmap(alt_k, ":m '<-2<cr>gv=gv", { desc = "Move line up", })

-- search case sensitive, whole word, and both
vim.cmd [[
  nnoremap <leader>/c /\C<left><left>
  nnoremap <leader>/w /\<\><left><left>
  nnoremap <leader>cw /\<\>\C<left><left><left><left>
]]
vim.cmd [[nnoremap / /\V]] -- search without regex

-- keep search result in the middle of the page
h.nmap("n", "nzz")
h.vmap("n", "nzz")
h.nmap("N", "Nzz")
h.vmap("N", "Nzz")

-- prevent x, c from overwriting the clipboard
h.map("", "x", [["_x]])
h.map("", "X", [["_X]])
h.map("", "c", [["_c]])
h.map("", "C", [["_C]])

local function count_based_keymap(movement)
  local count = vim.v.count
  if count > 0 then
    return movement
  else
    return "g" .. movement
  end
end

h.nmap("j", function() return count_based_keymap "j" end, { expr = true, },
  { desc = "Move down a line, but respect lines that wrap", })
h.nmap("k", function() return count_based_keymap "k" end, { expr = true, },
  { desc = "Move up a line, but respect lines that wrap", })

h.nmap("<C-y>", function() vim.cmd "tabclose" end, { desc = "Close the current tab", })
h.nmap("Y", h.user_cmd_cb "silent! bdelete!", { desc = "Close the current buffer", })
h.nmap("<leader>tw", function() error "use `Y` instead!" end)
h.nmap("<leader>ta", h.user_cmd_cb "silent! bufdo bdelete", { desc = "Close all buffers", })

-- TODO: use more
h.nmap([[<leader>']], [["]], { desc = "Set register", })
h.nmap("@", "@r", { desc = "Replay macro, assuming it's set to `r`", })

-- remaps to figure out in the future:
h.nmap("<C-t>", "<nop>", { desc = "TODO find a remap", })
h.nmap("<C-x>", "<nop>", { desc = "TODO find a remap", })
h.nmap("B", "<nop>", { desc = "TODO find a remap", })
h.nmap("W", "<nop>", { desc = "TODO find a remap", })
h.nmap("Q", "<nop>", { desc = "TODO find a remap", })
h.nmap("<leader>;", "<nop>", { desc = "TODO find a remap", })
h.nmap("<leader>i", "<nop>", { desc = "TODO find a remap", })
h.nmap("<leader>x", "<nop>", { desc = "TODO find a remap", })
h.nmap("<leader>b", "<nop>", { desc = "TODO find a remap", })
h.nmap("<leader>n", "<nop>", { desc = "TODO find a remap", })
h.nmap("<leader>,", "<nop>", { desc = "TODO find a remap", })
h.nmap("<leader>.", "<nop>", { desc = "TODO find a remap", })
