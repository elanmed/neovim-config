vim.api.nvim_create_autocmd("CursorMoved", {
  group = vim.api.nvim_create_augroup("CenterScreen", { clear = true, }),
  callback = function(args)
    local excluded_fts = { "tree", "nvim-undotree", "rg-far", }
    if vim.list_contains(excluded_fts, vim.bo[args.buf].filetype) then return end
    vim.cmd.normal { "zz", bang = true, }
  end,
  desc = "Center the screen on movement",
})

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
  callback = function() vim.highlight.on_yank() end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function()
    vim.fn.matchadd("Todo", [[\<\(TODO\|FIXME\|HACK\|XXX\)\>]])
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
local function highlight_hex_colors(buffer)
  vim.api.nvim_buf_clear_namespace(buffer, hex_ns_id, 0, -1)
  local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
  for row_1i, line in ipairs(lines) do
    local row_0i = row_1i - 1

    local start_pos_1i = 1
    while true do
      local match_start_1i, match_end_1i = line:find("#%x%x%x%x%x%x", start_pos_1i)
      if not match_start_1i then break end
      local match_start_0i = match_start_1i - 1

      local hex_color = line:sub(match_start_1i, match_end_1i)
      local group_name = "HexColor_" .. hex_color:sub(2)
      vim.api.nvim_set_hl(0, group_name, { bg = hex_color, fg = foreground_for_hex(hex_color), })
      vim.api.nvim_buf_set_extmark(buffer, hex_ns_id, row_0i, match_start_0i, {
        end_col = match_end_1i,
        hl_group = group_name,
      })
      start_pos_1i = match_end_1i + 1
    end
  end
end

local timer = nil
vim.api.nvim_create_autocmd({ "BufWinEnter", "TextChanged", "TextChangedI", }, {
  callback = function(event)
    if timer then vim.fn.timer_stop(timer) end
    timer = vim.fn.timer_start(500, function()
      if not vim.api.nvim_buf_is_valid(event.buf) then return end
      if vim.api.nvim_get_current_buf() ~= event.buf then return end
      highlight_hex_colors(event.buf)
    end)
  end,
})

-- TODO convert to lua
-- https://github.com/mrjones2014/smart-splits.nvim/blob/6c7c64b6e1be6eb95fd9583c0969e0df625c6cd6/autoload/smart_splits.vim#L51-L62
vim.cmd [[
function! s:is_nvim_var(val)
  if a:val == "true"
    return printf("\033]1337;SetUserVar=IS_NVIM=dHJ1ZQ==\007")
  elseif a:val == "false"
    return printf("\033]1337;SetUserVar=IS_NVIM=ZmFsc2U=\007")
  endif
endfunction
]]

local function write_var(var)
  if vim.fn.filewritable "/dev/fd/2" == require "helpers".vimscript_true then
    vim.fn.writefile({ var, }, "/dev/fd/2", "b")
  else
    vim.fn.chansend(vim.v.stderr, var)
  end
end

vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("SetWeztermIsNvimVar", { clear = true, }),
  callback = function()
    write_var(vim.fn["s:is_nvim_var"] "true")
  end,
})

vim.api.nvim_create_autocmd("VimLeave", {
  group = vim.api.nvim_create_augroup("UnSetWeztermIsNvimVar", { clear = true, }),
  callback = function()
    write_var(vim.fn["s:is_nvim_var"] "false")
  end,
})
