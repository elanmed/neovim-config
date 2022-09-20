package.path = package.path .. ";../?.lua"
local h = require("settings.helpers")

h.nmap("<leader>af", "<C-6>") -- alternate file
h.nmap("J", "gJ") -- J without whitespace
h.nmap("<leader>o", "o<esc>")
h.nmap("<leader>O", "O<esc>")
h.nmap("<leader>rr", [[viw"_dP]])
h.nmap("<leader>r;", "@:") -- repeat last command
h.nmap([[<leader>']], [["]]) -- for setting register
h.nmap("<leader>vs", "<cmd>vsplit<cr>")
h.nmap("<leader>p", "<cmd>pu<cr>") -- paste on line below
h.nmap("<leader>P", "<cmd>pu!<cr>") -- paste on line above

h.nmap("<leader>gd", "<cmd>NvimTreeClose<cr>:DiffviewOpen<cr>")
h.nmap("<leader>gq", "<cmd>DiffviewClose<cr>")
h.nmap("<leader>mp", "<cmd>MarkdownPreview<cr>")

-- duplicate lines
h.nmap("<leader>dl", "yyp")
h.vmap("<leader>dl", "y`>p") -- move to end of selection, then yank

h.nmap("<leader>s", "<cmd>w<cr>")
h.nmap("<leader>w", "<cmd>q<cr>")
h.nmap("<leader>q", "<cmd>qa<cr>")

-- hard to reach keys that can't be easily replaced with a snippet
h.imap("<C-h>", "=")
h.imap("<C-j>", "()<left>")
h.imap("<C-k>", "-")
h.imap("<C-l>", "_")

-- copy path of file
h.nmap("<leader>ip", [[<cmd>let @+ = expand("%")<cr>]])
h.vmap("<leader>ip", [[<cmd>let @+ = expand("%")<cr>]])

-- keeps lines highlighted while indenting
h.vmap("<", "<gv")
h.vmap(">", ">gv")

-- focusing
h.nmap("<leader>f", "<C-w>w") -- toggle
h.nmap("<leader>h", "<C-w>h") -- toggle
h.nmap("<leader>j", "<C-w>j") -- toggle
h.nmap("<leader>k", "<C-w>k") -- toggle
h.nmap("<leader>l", "<C-w>l") -- toggle

-- quickfix list
h.nmap("gn", "<cmd>cnext<cr>")
h.nmap("gp", "<cmd>cprevious<cr>")
h.nmap("ge", "<cmd>copen<cr>")
h.nmap("gq", "<cmd>cclose<cr>")

-- move lines up and down with alt-j, alt-k
h.nmap("∆", "<cmd>m .+1<cr>==")
h.nmap("˚", "<cmd>m .-2<cr>==")
h.imap("∆", "<esc><cmd>m .+1<cr>==gi")
h.imap("˚", "<esc><cmd>m .-2<cr>==gi")
h.vmap("∆", "<cmd>m '>+1<cr>gv=gv")
h.vmap("˚", "<cmd>m '<-2<cr>gv=gv")

-- search case sensitive, whole word, and both
vim.cmd([[
  noremap <leader>/c /\C<left><left>
  noremap <leader>/w /\<\><left><left>
  noremap <leader>cw /\<\>\C<left><left><left><left>
]])

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

-- TODO: convert this to lua
vim.cmd([[
  nnoremap <expr> j v:count ? 'j' : 'gj'
  nnoremap <expr> k v:count ? 'k' : 'gk'
]])

vim.cmd([[
  let g:VM_maps = {}
  let g:VM_maps["Add Cursor Down"] = '<C-k>'
]])
