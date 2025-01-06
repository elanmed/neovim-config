local h = require "shared.helpers"

-- delay when using h.*map
vim.cmd "nnoremap ; :"
vim.cmd "vnoremap ; :"
vim.cmd "inoremap <c-t> <c-o>:Snippet<space>"
h.map({ "n", "v", }, "<c-c>", function() print "snippets only supported in insert mode!" end)

vim.cmd [[
  nnoremap <leader>s :%s/\<\>\C/<left><left><left><left><left>
]]
h.map({ "n", }, "<leader>af", "<C-6>", { desc = "Alternate file", })
h.map({ "n", }, "<leader>va", "ggVG", { desc = "Select all", })
h.map({ "n", }, "<bs>", "b")
h.map({ "n", }, "*", "*N")
h.map({ "n", }, "<leader>f", "<C-w>w", { desc = "Toggle focus between windows", })
h.map({ "n", }, "<leader>e", h.user_cmd_cb "e", { desc = "Reload buffer", })
h.map({ "n", }, "<leader>vs", h.user_cmd_cb "vsplit")

h.map({ "i", }, "<C-e>", "<C-o>$")
h.map({ "n", "v", }, "<C-e>", "$")

h.map({ "i", }, "<C-a>", "<C-o>0")
h.map({ "n", "v", }, "<C-a>", "0")

h.map({ "n", }, "<leader>o", "o<esc>")
h.map({ "n", }, "<leader>O", "O<esc>")

h.map({ "n", }, "E", [[viw"_dP]], { desc = "pastE without overwriting the default register", }) -- TODO: find a better remap
h.map({ "n", }, "<leader>p", h.user_cmd_cb "pu", { desc = "Paste on the line below", })
h.map({ "n", }, "<leader>P", h.user_cmd_cb "pu!", { desc = "Paste on the line above", })

h.map({ "n", }, "<leader>dl", [["zyy"zp]], { desc = "Duplicate the current line", })
h.map({ "v", }, "<leader>dl", [["zy`>"zp]], { desc = "Duplicate the current line", }) -- move to end of selection, then yank

h.map({ "n", }, "<leader>w", h.user_cmd_cb "w", { desc = "Save", })
h.map({ "n", }, "<leader>q", h.user_cmd_cb "q", { desc = "Quit", })

h.map({ "n", }, "<leader>ka", function() vim.fn.setreg("+", vim.fn.expand "%:p") end,
  { desc = "C(K)opy the absolute path of a file", })
h.map({ "n", }, "<leader>kr", function() vim.fn.setreg("+", vim.fn.expand "%:~:.") end,
  { desc = "C(K)opy the relative path of a file", })

h.map({ "v", }, "<", "<gv", { desc = "Outdent, while keeping selection", })
h.map({ "v", }, ">", ">gv", { desc = "Indent, while keeping selection", })

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

h.map({ "n", }, "Z", "gJ", { desc = "J without whitespace", })
h.map({ "n", }, "J", h.user_cmd_cb "Cnext", { desc = "Move to the next item in the quickfix list", })
h.map({ "n", }, "K", h.user_cmd_cb "Cprev", { desc = "Move to the prev item in the quickfix list", })

h.map({ "n", }, "gn", "gt", { desc = "Go to the next tab", })
h.map({ "n", }, "gp", "gT", { desc = "Go to the prev tab", })

h.map({ "n", }, "ge", h.user_cmd_cb "copen 25", { desc = "Open the quickfix list", })
h.map({ "n", }, "gq", h.user_cmd_cb "cclose", { desc = "Close the quickfix list", })

local alt_j = h.is_mac() and "∆" or "<A-j>"
local alt_k = h.is_mac() and "˚" or "<A-k>"

h.map({ "n", }, alt_j, ":m .+1<cr>==", { desc = "Move line down", })
h.map({ "n", }, alt_k, ":m .-2<cr>==", { desc = "Move line up", })
h.map({ "i", }, alt_j, "<esc>:m .+1<cr>==gi", { desc = "Move line down", })
h.map({ "i", }, alt_k, "<esc>:m .-2<cr>==gi", { desc = "Move line up", })
h.map({ "v", }, alt_j, ":m '>+1<cr>gv=gv", { desc = "Move line down", })
h.map({ "v", }, alt_k, ":m '<-2<cr>gv=gv", { desc = "Move line up", })

-- search case sensitive, whole word, and both
vim.cmd [[
  nnoremap <leader>/c /\C<left><left>
  nnoremap <leader>/w /\<\><left><left>
  nnoremap <leader>cw /\<\>\C<left><left><left><left>
]]
vim.cmd [[nnoremap / /\V]] -- search without regex

-- keep search result in the middle of the page
h.map({ "n", "v", }, "n", "nzz")
h.map({ "n", "v", }, "N", "Nzz")

-- prevent x, c from overwriting the clipboard
h.map({ "n", "v", "i", }, "x", [["_x]])
h.map({ "n", "v", "i", }, "X", [["_X]])
h.map({ "n", "v", "i", }, "c", [["_c]])
h.map({ "n", "v", "i", }, "C", [["_C]])

local function count_based_keymap(movement)
  local count = vim.v.count
  if count > 0 then
    return movement
  else
    return "g" .. movement
  end
end

h.map({ "n", }, "j", function() return count_based_keymap "j" end, { expr = true, },
  { desc = "Move down a line, but respect lines that wrap", })
h.map({ "n", }, "k", function() return count_based_keymap "k" end, { expr = true, },
  { desc = "Move up a line, but respect lines that wrap", })

h.map({ "n", "i", "v", }, "<C-y>", function() vim.cmd "tabclose" end, { desc = "Close the current tab", })
h.map({ "n", }, "Y", h.user_cmd_cb "silent! bdelete!", { desc = "Close the current buffer", })
h.map({ "n", }, "<leader>tw", function() error "use `Y` instead!" end)
h.map({ "n", }, "<leader>ta", h.user_cmd_cb "silent! bufdo bdelete", { desc = "Close all buffers", })

-- TODO: use more
h.map({ "n", }, [[<leader>']], [["]], { desc = "Set register", })
h.map({ "n", }, "@", "@r", { desc = "Replay macro, assuming it's set to `r`", })

h.map({ "n", "v", }, "<c-x>", "{")
h.map({ "n", "v", }, "<c-c>", "}")

-- remaps to figure out in the future:
h.map({ "n", }, "B", "<nop>", { desc = "TODO find a remap", })
h.map({ "n", }, "<leader>;", "<nop>", { desc = "TODO find a remap", })
h.map({ "n", }, "<leader>i", "<nop>", { desc = "TODO find a remap", })
h.map({ "n", }, "<leader>x", "<nop>", { desc = "TODO find a remap", })
h.map({ "n", }, "<leader>b", "<nop>", { desc = "TODO find a remap", })
h.map({ "n", }, "<leader>n", "<nop>", { desc = "TODO find a remap", })
h.map({ "n", }, "<leader>,", "<nop>", { desc = "TODO find a remap", })
h.map({ "n", }, "<leader>.", "<nop>", { desc = "TODO find a remap", })
