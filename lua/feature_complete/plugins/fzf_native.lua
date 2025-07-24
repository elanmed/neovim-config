local function extend(...)
  local result = {}
  for _, list in ipairs { ..., } do
    vim.list_extend(result, list)
  end
  return result
end

local function fzf_opts(...)
  return table.concat(extend(...), " ")
end

local default_opts_tbl = {
  "--cycle",
  "--style=full",
  "--preview-window=up:50%",
  "--bind=ctrl-d:preview-page-down",
  "--bind=ctrl-u:preview-page-up",
}

local preview_opts_tbl = {
  "--preview='~/.local/share/nvim/site/pack/paqs/start/fzf.vim/bin/preview.sh {}'",
}

local multi_opts_tbl = {
  "--multi",
  "--bind=ctrl-a:toggle-all",
  "--bind=tab:select+down",
  "--bind=shift-tab:up+deselect",
}

local single_opts_tbl = {
  "--bind=tab:down",
  "--bind=shift-tab:up",
}

local base_window_opts = {
  width = 1,
  relative = true,
  yoffset = 1,
  border = "none",
}
local without_preview_window_opts = vim.tbl_extend("force", base_window_opts, { height = 0.5, })
local with_preview_window_opts = vim.tbl_extend("force", base_window_opts, { height = 0.85, })

local function set_preview_window_opts(preview)
  -- vim.api.nvim_set_var("fzf_layout", { window = preview and with_preview_window_opts or without_preview_window_opts, })
  vim.api.nvim_set_var("fzf_layout", { window = with_preview_window_opts, })
end

vim.api.nvim_set_var("fzf_vim", {
  helptags_options = fzf_opts(default_opts_tbl, single_opts_tbl),
  marks_options = fzf_opts(default_opts_tbl, single_opts_tbl),
  buffers_options = fzf_opts(default_opts_tbl, single_opts_tbl),
  files_options = fzf_opts(default_opts_tbl, multi_opts_tbl, { "--prompt='Files> '", }),
})

vim.keymap.set("n", "<leader>h", function()
  set_preview_window_opts(true)
  vim.cmd "Helptags"
end)
vim.keymap.set("n", "<leader>zm", function()
  set_preview_window_opts(false)
  vim.cmd "Marks"
end)
vim.keymap.set("n", "<leader>b", function()
  set_preview_window_opts(true)
  vim.cmd "Buffers"
end)
vim.keymap.set("n", "<leader>zf", function()
  set_preview_window_opts(true)
  vim.cmd "Files"
end)

vim.keymap.set("n", "<leader>z;", function()
  set_preview_window_opts(false)
  vim.fn["fzf#vim#command_history"] {
    options = fzf_opts(default_opts_tbl, single_opts_tbl),
  }
  -- TODO: fzf_vim options entry
  -- vim.cmd "History:"
end)
vim.keymap.set("n", "<leader>zi", function()
  set_preview_window_opts(true)
  vim.fn["fzf#vim#gitfiles"]("?", {
    options = fzf_opts(default_opts_tbl, single_opts_tbl),
  })
  -- TODO: fzf_vim options entry
  -- vim.cmd "GFiles?"
end)

vim.keymap.set("n", "<leader>za", function()
  local script = os.getenv "HOME" .. "/.dotfiles/neovim/.config/nvim/rg-cmd.sh"

  -- https://junegunn.github.io/fzf/tips/ripgrep-integration/
  local function rg_with_custom_flags()
    local spec = {
      source = ":",
      options = {
        "--cycle",
        "--style=full",
        "--disabled",
        "--ansi",
        "--prompt", "Rg> ",
        "--header=-e by *.[ext] :: -f by file :: -d by **/[dir]/** :: -c by case sensitive :: -nc by case insensitive :: -w by whole word :: -nw by partial word",
        "--delimiter", ":",
        ("--bind=change:reload:%s {q} || true"):format(script),
        "--preview=bat --style=numbers --color=always --highlight-line {2} {1}",
      },
    }

    vim.fn["fzf#run"](vim.fn["fzf#wrap"]("", spec))
  end

  rg_with_custom_flags()
end)

-- vim.keymap.set("n", "<leader>zm", function()
--   local marks = {}
--   for _, entry in pairs(vim.fn.getmarklist()) do
--     local file = vim.fs.normalize(entry.file)
--     if not vim.startswith(file, vim.fn.getcwd()) then
--       goto continue
--     end
--     local rel = vim.fs.relpath(vim.fn.getcwd(), file)
--     local formatted = ("%s:%s"):format(entry.mark, rel)
--     table.insert(marks, formatted)
--
--     ::continue::
--   end
--
--   vim.fn["fzf#run"] {
--     source = marks,
--     options = table.concat({
--         [[--preview="echo {} | awk -F':' '{print \$NF}' | xargs bat --style=plain --color=always"]],
--       },
--       " "),
--     sinklist = function(list)
--       local qf_list = vim.tbl_map(function(file)
--         local trimmed_file = (file):match "([^:]+)$"
--         return { filename = vim.fs.relpath(vim.fn.getcwd(), trimmed_file), }
--       end, list)
--       vim.fn.setqflist(qf_list, "a")
--       vim.cmd "copen"
--     end,
--   }
-- end)
