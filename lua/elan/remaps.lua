package.path = package.path .. ";../?.lua"
local h = require("elan.helpers")

-- set leader before importing remaps with <leader>
h.map("", "<space>", "<nop>", { silent = true })
h.let.mapleader = " "

h.nmap("W", "0")
h.vmap("W", "0")
h.nmap("E", "$")
h.vmap("E", "$")

h.nmap("H", "L")
h.vmap("H", "L")
h.nmap("L", "H")
h.vmap("L", "H")

h.nmap("<leader>o", "o<esc>")
h.nmap("<leader>O", "O<esc>")
h.nmap("<leader>rr", "viwp")
h.nmap("<leader>r;", "@:") -- repeat last command
h.nmap([[<leader>']], [["]])
h.nmap("<leader>p", ":pu<cr>") -- paste on line below
h.nmap("<leader>P", ":pu!<cr>") -- paste on line above
h.nmap("<leader>gb", ":Git blame")
h.nmap("<leader>gd", ":NvimTreeClose<cr>:DiffviewOpen<cr>")
h.nmap("<leader>gq", ":DiffviewClose<cr>")
h.nmap("<leader>vs", ":vsplit<cr>")
h.nmap("<leader>mp", ":MarkdownPreview<cr>")

h.nmap("<leader>s", ":w<cr>")
h.nmap("<leader>w", ":q<cr>")
h.nmap("<leader>q", ":qa<cr>")

-- copy path of file
h.nmap("<leader>yy", [[:let @+ = expand("%")<cr>]])
h.vmap("<leader>yy", [[:let @+ = expand("%")<cr>]])

-- keeps lines highlighted while indenting
h.vmap("<", "<gv")
h.vmap(">", ">gv")

-- focusing
h.nmap("<leader>f", "<C-w>w") -- toggle
h.nmap("<leader>h", "<C-w>h")
h.nmap("<leader>l", "<C-w>l")
h.nmap("<leader>j", "<C-w>j")
h.nmap("<leader>k", "<C-w>k")

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
