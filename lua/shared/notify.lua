local timer = nil

--- @param message string
--- @param level vim.log.levels|nil
--- @param _opts table|nil
local function notify(message, level, _opts)
  if timer then vim.fn.timer_stop(timer) end

  local level_to_hl_group = {
    [vim.log.levels.DEBUG] = "NotifyDebug",
    [vim.log.levels.ERROR] = "NotifyError",
    [vim.log.levels.INFO] = "NotifyInfo",
    [vim.log.levels.OFF] = "NotifyOff",
    [vim.log.levels.TRACE] = "NotifyTrace",
    [vim.log.levels.WARN] = "NotifyWarn",
  }
  local hl_group = level_to_hl_group[level]

  local max_len = vim.o.columns - 1
  if #message > max_len then message = message:sub(1, max_len - 1) .. "…" end

  local add_to_history = true
  vim.api.nvim_echo({ { message, hl_group, }, }, add_to_history, {})
  timer = vim.fn.timer_start(2000, function()
    if vim.fn.mode() == "n" then vim.cmd [[normal! :<Esc>]] end
  end)
end

vim.notify = notify
