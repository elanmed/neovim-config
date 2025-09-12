local h = require "helpers"
local fzf = require "shared.fzf"

vim.cmd "set wildchar=<C-n>"

vim.opt.scrolloff = 999

-- removing banner causes a bug where the terminal flickers
-- vim.g.netrw_banner = 0 -- removes banner at the top

vim.keymap.set("n", "<C-f>", function()
  if vim.bo.filetype == "netrw" then
    while vim.bo.filetype == "netrw" do
      vim.cmd "bdelete"
    end
  else
    vim.cmd "Explore %:p:h"
  end
end, { desc = "Toggle netrw, focusing the current buffer", })

vim.keymap.set("n", "<leader>f", function()
  fzf.fzf {
    source = "fd --hidden --type f --exclude .git --exclude node_modules --exclude dist",
    height = "half",
    options = fzf.extend(fzf.default_opts, fzf.multi_select_opts),
    sinklist = function(entries)
      for _, entry in ipairs(entries) do
        vim.cmd("edit " .. entry)
      end
    end,
  }
end)

vim.keymap.set("n", "<C-n>", h.keys.vim_cmd_cb "cnext")
vim.keymap.set("n", "<C-p>", h.keys.vim_cmd_cb "cprev")

local function skip_or_insert_pair(char)
  return function()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_right = line:sub(col + 1, col + 1)
    if char_right == char then
      return "<right>"
    else
      return char
    end
  end
end

local function skip_or_insert_same(char)
  return function()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local char_right = line:sub(col + 1, col + 1)
    if char_right == char then
      return "<right>"
    else
      return char .. char .. "<left>"
    end
  end
end

vim.keymap.set("i", "(", "()<left>")
vim.keymap.set("i", "{", "{}<left>")
vim.keymap.set("i", "[", "[]<left>")

vim.keymap.set("i", ")", skip_or_insert_pair ")", { expr = true, })
vim.keymap.set("i", "}", skip_or_insert_pair "}", { expr = true, })
vim.keymap.set("i", "]", skip_or_insert_pair "]", { expr = true, })

vim.keymap.set("i", "`", skip_or_insert_same "`", { expr = true, })
vim.keymap.set("i", [[']], skip_or_insert_same [[']], { expr = true, })
vim.keymap.set("i", [["]], skip_or_insert_same [["]], { expr = true, })

vim.keymap.set("i", "<bs>", function()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
  local char_right = line:sub(col + 1, col + 1)
  if char_right == "" then return "<bs>" end

  local char = line:sub(col, col)
  local left_to_right_pair = {
    ["("] = ")",
    ["{"] = "}",
    ["["] = "]",
    ["`"] = "`",
    ["'"] = "'",
    ['"'] = '"',
  }

  if left_to_right_pair[char] == nil then return "<bs>" end
  if left_to_right_pair[char] ~= char_right then return "<bs>" end
  return "<right><bs><bs>"
end, { expr = true, })

vim.keymap.set("c", "/", function()
  if vim.fn.wildmenumode() == h.vimscript_true then
    return "<C-y>"
  else
    return "/"
  end
end, { expr = true, })
