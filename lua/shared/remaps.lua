local h = require "shared.helpers"

-- delay when using h.keys.map
vim.cmd "inoremap <C-t> <C-o>:Snippet<space>"
h.keys.map({ "n", "v", }, "<C-t>", function() print "snippets only supported in insert mode!" end)

vim.cmd [[
  nnoremap <leader>s :%s/\<\>\C/<left><left><left><left><left>
]]
h.keys.map({ "n", }, "<leader>af", "<C-6>", { desc = "Alternate file", })
h.keys.map({ "n", }, "<leader>va", "ggVG", { desc = "Select all", })
h.keys.map({ "n", }, "*", "*N")
h.keys.map({ "n", }, "<leader>f", "<C-w>w", { desc = "Toggle focus between windows", })
h.keys.map({ "n", }, "<leader>e", h.keys.user_cmd_cb "e", { desc = "Reload buffer", })
h.keys.map({ "n", }, "<leader>vs", h.keys.user_cmd_cb "vsplit")
h.keys.map({ "n", }, "<bs>", "b")

h.keys.map({ "i", }, "<C-e>", "<C-o>$")
h.keys.map({ "n", "v", }, "<C-e>", "$")

h.keys.map({ "i", }, "<C-a>", "<C-o>0")
h.keys.map({ "n", "v", }, "<C-a>", "0")

h.keys.map({ "n", }, "<leader>o", "o<esc>")
h.keys.map({ "n", }, "<leader>O", "O<esc>")

h.keys.map({ "n", }, "E", [[viw"_dP]], { desc = "pastE without overwriting the default register", }) -- TODO: find a better remap
h.keys.map({ "n", }, "<leader>p", h.keys.user_cmd_cb "pu", { desc = "Paste on the line below", })
h.keys.map({ "n", }, "<leader>P", h.keys.user_cmd_cb "pu!", { desc = "Paste on the line above", })

h.keys.map({ "n", }, "<leader>dl", [["zyy"zp]], { desc = "Duplicate the current line", })
h.keys.map({ "v", }, "<leader>dl", [["zy`>"zp]], { desc = "Duplicate the current line", }) -- move to end of selection, then yank

h.keys.map({ "n", }, "<leader>w", h.keys.user_cmd_cb "w", { desc = "Save", })
h.keys.map({ "n", }, "<leader>q", h.keys.user_cmd_cb "q", { desc = "Quit", })

h.keys.map({ "n", }, "<leader>ka", function() vim.fn.setreg("+", vim.fn.expand "%:p") end,
  { desc = "C(K)opy the absolute path of a file", })
h.keys.map({ "n", }, "<leader>kr", function() vim.fn.setreg("+", vim.fn.expand "%:~:.") end,
  { desc = "C(K)opy the relative path of a file", })

h.keys.map({ "v", }, "<", "<gv", { desc = "Outdent, while keeping selection", })
h.keys.map({ "v", }, ">", ">gv", { desc = "Indent, while keeping selection", })

--- @param try string
--- @param catch string
local function gen_circular_next_prev(try, catch)
  local success, _ = pcall(vim.cmd, try)
  if not success then
    pcall(vim.cmd, catch)
  end
end

vim.api.nvim_create_user_command("Cnext", function() gen_circular_next_prev("cnext", "cfirst") end, {})
vim.api.nvim_create_user_command("Cprev", function() gen_circular_next_prev("cprev", "clast") end, {})
vim.api.nvim_create_user_command("Lnext", function() gen_circular_next_prev("lnext", "lfirst") end, {})
vim.api.nvim_create_user_command("Lprev", function() gen_circular_next_prev("lprev", "llast") end, {})

h.keys.map({ "n", }, "Z", "gJ", { desc = "J without whitespace", })
h.keys.map({ "n", }, "J", h.keys.user_cmd_cb "Cnext", { desc = "Move to the next item in the quickfix list", })
h.keys.map({ "n", }, "K", h.keys.user_cmd_cb "Cprev", { desc = "Move to the prev item in the quickfix list", })

-- TODO: figure out a way to clear only one list, not all
-- delete all quickfix lists
h.keys.map({ "n", }, "gc", h.keys.user_cmd_cb "cex \"\"", { desc = "Clear all quickfix lists", })

h.keys.map({ "n", }, "gn", "gt", { desc = "Go to the next tab", })
h.keys.map({ "n", }, "gp", "gT", { desc = "Go to the prev tab", })

h.keys.map({ "n", }, "ge", h.keys.user_cmd_cb "copen 15", { desc = "Open the quickfix list", })
h.keys.map({ "n", }, "gq", h.keys.user_cmd_cb "cclose", { desc = "Close the quickfix list", })

-- TODO: issues with mac
local alt_j = h.keys.is_linux() and "<A-j>" or "∆"
local alt_k = h.keys.is_linux() and "<A-k>" or "˚"

h.keys.map({ "n", }, alt_j, ":m .+1<cr>==", { desc = "Move line down", })
h.keys.map({ "n", }, alt_k, ":m .-2<cr>==", { desc = "Move line up", })
h.keys.map({ "i", }, alt_j, "<esc>:m .+1<cr>==gi", { desc = "Move line down", })
h.keys.map({ "i", }, alt_k, "<esc>:m .-2<cr>==gi", { desc = "Move line up", })
h.keys.map({ "v", }, alt_j, ":m '>+1<cr>gv=gv", { desc = "Move line down", })
h.keys.map({ "v", }, alt_k, ":m '<-2<cr>gv=gv", { desc = "Move line up", })

-- search case sensitive, whole word, and both
vim.cmd [[
  nnoremap <leader>/c /\C<left><left>
  nnoremap <leader>/w /\<\><left><left>
  nnoremap <leader>cw /\<\>\C<left><left><left><left>
]]
vim.cmd [[nnoremap / /\V]] -- search without regex

h.keys.map({ "n", "v", }, "n", "nzz")
h.keys.map({ "n", "v", }, "N", "Nzz")

-- prevent x, c from overwriting the clipboard
h.keys.map({ "", }, "x", [["_x]])
h.keys.map({ "", }, "X", [["_X]])
h.keys.map({ "", }, "c", [["_c]])
h.keys.map({ "", }, "C", [["_C]])

local function count_based_keymap(movement)
  local count = vim.v.count
  if count > 0 then
    return movement
  else
    return "g" .. movement
  end
end

h.keys.map({ "n", }, "j", function() return count_based_keymap "j" end,
  { expr = true, desc = "j, but respect lines that wrap", })
h.keys.map({ "n", }, "k", function() return count_based_keymap "k" end,
  { expr = true, desc = "k, but respect lines that wrap", })

h.keys.map({ "n", "v", "i", }, "<C-y>", function() vim.cmd "tabclose" end, { desc = "Close the current tab", })
h.keys.map({ "n", }, "Y", h.keys.user_cmd_cb "silent! bdelete!", { desc = "Close the current buffer", })
h.keys.map({ "n", }, "<leader>tw", function() error "use `Y` instead!" end)
h.keys.map({ "n", }, "<leader>ta", h.keys.user_cmd_cb "silent! bufdo bdelete", { desc = "Close all buffers", })
-- https://github.com/vim/vim/issues/1016#issuecomment-1226200584
local function clean_empty_bufs()
  for _, buf in pairs(vim.api.nvim_list_bufs()) do
    if
        vim.api.nvim_buf_get_name(buf) == ""
        and not vim.api.nvim_get_option_value("modified", {
          buf = buf,
        })
        and vim.api.nvim_buf_is_loaded(buf)
    then
      local opts = {}
      vim.api.nvim_buf_delete(buf, opts)
    end
  end
end
h.keys.map({ "n", }, "<leader>te", clean_empty_bufs, { desc = "Close all empty buffers", })
-- TODO: find a better event
-- vim.api.nvim_create_autocmd({ "BufEnter", }, {
--   pattern = "*",
--   callback = clean_empty_bufs,
-- })
h.keys.map({ "n", }, "<leader>to", function()
  vim.cmd "%bdelete" -- delete all buffers
  vim.cmd "edit#"    -- open the last buffer
end)


-- TODO: use more
h.keys.map({ "n", }, [[<leader>']], [["]], { desc = "Set register", })
h.keys.map({ "n", }, "@", "@r", { desc = "Replay macro, assuming it's set to `r`", })

h.keys.map({ "i", }, "<C-x>", "<C-o>{")
h.keys.map({ "n", "v", }, "<c-x>", "{")
h.keys.map({ "i", }, "<C-c>", "<C-o>}")
h.keys.map({ "n", "v", }, "<C-c>", "}")

-- remaps to figure out in the future:
h.keys.map({ "n", }, "B", "<nop>", { desc = "TODO find a remap", })
h.keys.map({ "n", }, "<leader>;", "<nop>", { desc = "TODO find a remap", })
h.keys.map({ "n", }, "<leader>i", "<nop>", { desc = "TODO find a remap", })
h.keys.map({ "n", }, "<leader>x", "<nop>", { desc = "TODO find a remap", })
h.keys.map({ "n", }, "<leader>b", "<nop>", { desc = "TODO find a remap", })
h.keys.map({ "n", }, "<leader>n", "<nop>", { desc = "TODO find a remap", })
h.keys.map({ "n", }, "<leader>,", "<nop>", { desc = "TODO find a remap", })
h.keys.map({ "n", }, "<leader>.", "<nop>", { desc = "TODO find a remap", })
