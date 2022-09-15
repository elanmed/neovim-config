package.path = package.path .. ";../?.lua"
local h = require("elan.helpers")

h.nmap("<leader>o", "o<esc>")
h.nmap("<leader>O", "O<esc>")
h.nmap("<leader>rr", "viwp")
h.nmap("<leader>r;", "@:") -- repeat last command
h.nmap([[<leader>']], [["]]) -- for setting register
h.nmap("<leader>p", ":pu<cr>") -- paste on line below
h.nmap("<leader>P", ":pu!<cr>") -- paste on line above
h.nmap("<leader>gd", ":NvimTreeClose<cr>:DiffviewOpen<cr>")
h.nmap("<leader>gq", ":DiffviewClose<cr>")
h.nmap("<leader>vs", ":vsplit<cr>")
h.nmap("<leader>mp", ":MarkdownPreview<cr>")
h.nmap("<leader>dl", "yyp")
h.vmap("<leader>dl", "yp")

h.nmap("<leader>s", ":w<cr>")
h.nmap("<leader>w", ":q<cr>")
h.nmap("<leader>q", ":qa<cr>")

h.imap("<C-j>", "=")
h.imap("<C-k>", "()<left>")

-- copy path of file
h.nmap("<leader>yy", [[:let @+ = expand("%")<cr>]])
h.vmap("<leader>yy", [[:let @+ = expand("%")<cr>]])

-- keeps lines highlighted while indenting
h.vmap("<", "<gv")
h.vmap(">", ">gv")

-- focusing
h.nmap("<leader>f", "<C-w>w") -- toggle
h.nmap("<leader>h", "<C-w>h") -- left
h.nmap("<leader>l", "<C-w>l") -- right
h.nmap("<leader>j", "<C-w>j") -- down
h.nmap("<leader>k", "<C-w>k") -- up

-- quickfix list
h.nmap("gn", ":cnext<cr>")
h.nmap("gp", ":cprevious<cr>")
h.nmap("ge", ":copen<cr>")
h.nmap("gq", ":cclose<cr>")

-- move lines up and down with alt-j, alt-k
h.nmap("∆", ":m .+1<cr>==")
h.nmap("˚", ":m .-2<cr>==")
h.imap("∆", "<esc>:m .+1<cr>==gi")
h.imap("˚", "<esc>:m .-2<cr>==gi")
h.vmap("∆", ":m '>+1<cr>gv=gv")
h.vmap("˚", ":m '<-2<cr>gv=gv")

-- search case sensitive, whole word, and both
vim.cmd([[
  noremap <leader>/c /\C<left><left>
  noremap <leader>/w /\<\><left><left>
  noremap <leader>cw /\<\>\C<left><left><left><left>
]])
h.nmap("n", "nzz")
h.vmap("n", "nzz")
h.nmap("N", "Nzz")
h.vmap("N", "Nzz")
