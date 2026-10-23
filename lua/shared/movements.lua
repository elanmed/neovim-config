--- @param direction "j"|"k"
--- @param num_lines number
local function smooth_scroll(direction, num_lines)
  local count = 0
  local function step()
    if count < num_lines then
      vim.cmd.normal { direction, bang = true }
      count = count + 1
      vim.defer_fn(step, 10)
    end
  end
  step()
end

local function get_half_page_lines()
  return math.floor(vim.api.nvim_win_get_height(0) / 2) - 1
end

vim.keymap.set({ "n", "v" }, "<C-d>", function()
  smooth_scroll("j", get_half_page_lines())
end, { desc = "Smooth-scroll a half-page down" })

vim.keymap.set({ "n", "v" }, "<C-u>", function()
  smooth_scroll("k", get_half_page_lines())
end, { desc = "Smooth-scroll a half-page up" })

--- @param direction "j"|"k"
local function get_lines_until_paragraph_break(direction)
  local row_1i = vim.api.nvim_win_get_cursor(0)[1]
  local row_0i = row_1i - 1

  local lines = (function()
    if direction == "j" then
      return vim.api.nvim_buf_get_lines(0, row_0i + 1, -1, false)
    end
    return require("helpers").tbl.reverse(vim.api.nvim_buf_get_lines(0, 0, row_0i, false))
  end)()

  for offset, line_text in ipairs(lines) do
    if line_text == "" then
      return offset
    end
  end

  return #lines
end

vim.keymap.set("n", "H", function()
  local count = get_lines_until_paragraph_break "k"
  smooth_scroll("k", count)
end, { desc = "{" })

vim.keymap.set("n", "L", function()
  local count = get_lines_until_paragraph_break "j"
  smooth_scroll("j", count)
end, { desc = "}" })

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("SmoothScroll", { clear = true }),
  callback = function(ev)
    local bname = vim.api.nvim_buf_get_name(ev.buf)
    local line_count = vim.api.nvim_buf_line_count(ev.buf)
    if
      require("helpers").utils.is_big_file { bname = bname, line_count = line_count }
      or ev.match == "java"
    then
      vim.keymap.set({ "n", "v" }, "<C-d>", "<C-d>", { buffer = true })
      vim.keymap.set({ "n", "v" }, "<C-u>", "<C-u>", { buffer = true })
    end
  end,
})
