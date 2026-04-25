local function smooth_scroll(direction)
  local lines = math.floor((vim.o.lines - 1) / 2) - 1
  local count = 0
  local function step()
    if count < lines then
      vim.cmd.normal { direction, bang = true, }
      count = count + 1
      vim.defer_fn(step, 10)
    end
  end
  step()
end

local function smooth_scroll_cb(direction)
  return function() smooth_scroll(direction) end
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("SmoothScroll", { clear = true, }),
  callback = function(ev)
    if ev.match == "java" then return end

    local bname = vim.api.nvim_buf_get_name(ev.buf)
    local line_count = vim.api.nvim_buf_line_count(ev.buf)
    if require "helpers".utils.is_big_file { bname = bname, line_count = line_count, } then return end

    vim.keymap.set({ "n", "v", }, "<C-d>", smooth_scroll_cb "j",
      { desc = "Smooth-scroll a half-page down", buf = ev.buf, })
    vim.keymap.set({ "n", "v", }, "<C-u>", smooth_scroll_cb "k",
      { desc = "Smooth-scroll a half-page up", buf = ev.buf, }
    )
  end,
})
