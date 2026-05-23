vim.o.pumheight = 10
vim.api.nvim_create_autocmd("CmdlineEnter", { callback = function() vim.o.pumheight = 5 end, })
vim.api.nvim_create_autocmd("CmdlineLeave", { callback = function() vim.o.pumheight = 10 end, })
vim.api.nvim_create_autocmd("CmdlineChanged", {
  pattern = { ":", "/", },
  callback = function()
    local cmdline = vim.fn.getcmdline()
    local cmdtype = vim.fn.getcmdtype()

    if cmdtype == "/" and cmdline:match "^\\V." then
      vim.fn.wildtrigger()
    elseif cmdtype == ":" then
      vim.fn.wildtrigger()
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("DisableAutoComments", { clear = true, }),
  callback = function()
    -- :h fo-table
    vim.o.formatoptions = "rl1j"
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("SetYankRing", { clear = true, }),
  callback = function()
    if vim.v.event.operator == "y" then
      require "helpers".utils.rotate_registers()
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("HighlightOnYank", { clear = true, }),
  callback = function() vim.hl.hl_op() end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function()
    -- TODO: delete?
    vim.fn.matchadd("Todo", [[\<\(TODO\|FIXME\)\>]])
  end,
})

local function foreground_for_hex(hex_color)
  local red = tonumber(hex_color:sub(2, 3), 16)
  local green = tonumber(hex_color:sub(4, 5), 16)
  local blue = tonumber(hex_color:sub(6, 7), 16)
  local luminance = (0.299 * red + 0.587 * green + 0.114 * blue) / 255
  if luminance > 0.5 then
    return "#000000"
  else
    return "#ffffff"
  end
end

local hex_ns_id = vim.api.nvim_create_namespace "HexColors"
--- @param bufnr number
local function highlight_hex_colors(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, hex_ns_id, 0, -1)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for row_1i, line in ipairs(lines) do
    local row_0i = row_1i - 1

    local start_pos_1i = 1
    while true do
      local match_start_1i, match_end_1i = line:find("#%x%x%x%x%x%x", start_pos_1i)
      if match_start_1i == nil then break end
      local match_start_0i = match_start_1i - 1

      local hex_color = line:sub(match_start_1i, match_end_1i)
      local group_name = "HexColor_" .. hex_color:sub(2)
      vim.api.nvim_set_hl(0, group_name, { bg = hex_color, fg = foreground_for_hex(hex_color), })
      vim.api.nvim_buf_set_extmark(bufnr, hex_ns_id, row_0i, match_start_0i, {
        end_col = match_end_1i,
        hl_group = group_name,
      })
      start_pos_1i = match_end_1i + 1
    end
  end
end

local hex_timer = nil
vim.api.nvim_create_autocmd({ "BufWinEnter", "TextChanged", "TextChangedI", }, {
  callback = function(event)
    if hex_timer then vim.fn.timer_stop(hex_timer) end
    hex_timer = vim.fn.timer_start(500, function()
      if not vim.api.nvim_buf_is_valid(event.buf) then return end
      if vim.api.nvim_get_current_buf() ~= event.buf then return end
      highlight_hex_colors(event.buf)
    end)
  end,
})

local ctags_timer = nil
vim.api.nvim_create_autocmd("BufWritePost", {
  callback = (function()
    if ctags_timer then vim.fn.timer_stop(ctags_timer) end

    ctags_timer = vim.fn.timer_start(5000, require "helpers".async(function()
      --- @param cmd string[]
      --- @return Promise
      local vim_system = function(cmd)
        return function(resolve)
          vim.system(cmd, function(out) resolve(out) end)
        end
      end

      local h = require "helpers"
      --- @type vim.SystemCompleted
      local out = h.await(vim_system { "git", "rev-parse", "--show-toplevel", })
      if out.code ~= 0 then return end
      if out.stdout == nil then return end

      local git_root = vim.trim(out.stdout)
      if git_root == nil then return end

      vim.system { "ctags", "-R", git_root, }
    end))
  end),
})
