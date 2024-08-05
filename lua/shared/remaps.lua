local h = require "shared.helpers"


vim.cmd("nnoremap ; :")
h.nmap(":", function() error "use ; instead!" end)
h.nmap("<leader>af", "<C-6>", { desc = "Alternate file" })
h.nmap("J", "gJ", { desc = "J without whitespace" })
-- h.nmap("<leader>e", [[viw"_dP]])
h.nmap("<leader>e", h.user_cmd_cb("e"), { desc = "Reload buffer" })
h.nmap([[<leader>']], [["]], { desc = "Set register" })
h.nmap("@", "@r", { desc = "Replay macro, assuming it's set to `r`" })
h.nmap("<leader>vs", h.user_cmd_cb("vsplit"))
h.nmap("<leader>va", "ggVG", { desc = "Select all" })
h.nmap("<bs>", "b")
h.nmap("*", "*N")
h.nmap("<leader>f", "<C-w>w", { desc = "Toggle focus between windows" })

h.nmap("<leader>o", "o<esc>")
h.nmap("<leader>O", "O<esc>")

h.nmap("<leader>p", h.user_cmd_cb "pu", { desc = "Paste on the line below" })
h.nmap("<leader>P", h.user_cmd_cb("pu!"), { desc = "Paste on the line above" })

h.nmap("<leader>dl", "yyp", { desc = "Duplicate the current line" })
h.vmap("<leader>dl", "y`>p", { desc = "Duplicate the current line" }) -- move to end of selection, then yank

h.nmap("<leader>s", function() error "use <leader>w instead!" end)
h.nmap("<leader>w", h.user_cmd_cb("w"), { desc = "Save" })
h.nmap("<leader>q", h.user_cmd_cb "q", { desc = "Quit" })

h.nmap("<leader>ia", function() vim.fn.setreg("+", vim.fn.expand("%:p")) end,
  { desc = "Copy the absolute path of a file" })
h.nmap("<leader>ir", function() vim.fn.setreg("+", vim.fn.expand("%:~:.")) end,
  { desc = "Copy the relative path of a file" })

h.vmap("<", "<gv", { desc = "Outdent, while keeping selection" })
h.vmap(">", ">gv", { desc = "Indent, while keeping selection" })

h.nmap("gn", function()
  vim.cmd("Cnext")
  vim.cmd("normal! zz")
end, { desc = "Move to the next item in the quickfix list" })
h.nmap("gp", function()
  vim.cmd("Cprev")
  vim.cmd("normal! zz")
end, { desc = "Move to the previous item in the quickfix list" })
h.nmap("ge", h.user_cmd_cb("copen 25"), { desc = "Open the quickfix list" })
h.nmap("gq", h.user_cmd_cb("cclose"), { desc = "Close the quickfix list" })

local alt_j = h.is_mac() and "∆" or "<A-j>"
local alt_k = h.is_mac() and "˚" or "<A-k>"

h.nmap(alt_j, ":m .+1<cr>==", { desc = "Move line down" })
h.nmap(alt_k, ":m .-2<cr>==", { desc = "Move line up" })
h.imap(alt_j, "<esc>:m .+1<cr>==gi", { desc = "Move line down" })
h.imap(alt_k, "<esc>:m .-2<cr>==gi", { desc = "Move line up" })
h.vmap(alt_j, ":m '>+1<cr>gv=gv", { desc = "Move line down" })
h.vmap(alt_k, ":m '<-2<cr>gv=gv", { desc = "Move line up" })

-- search case sensitive, whole word, and both
vim.cmd([[
  noremap <leader>/c /\C<left><left>
  noremap <leader>/w /\<\><left><left>
  noremap <leader>cw /\<\>\C<left><left><left><left>
]])
vim.cmd([[nnoremap / /\V]]) -- search without regex


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

h.nmap("j", function() return count_based_keymap("j") end, { expr = true },
  { desc = "Move down a line, but respect lines that wrap" })
h.nmap("k", function() return count_based_keymap("k") end, { expr = true },
  { desc = "Move up a line, but respect lines that wrap" })

-- free up o_ remaps for harpoon
h.nmap("oo", "o")

-- remaps to figure out in the future:
h.nmap("U", function() end, { desc = "TODO find a remap" })
h.nmap("Z", function() end, { desc = "TODO find a remap" })
