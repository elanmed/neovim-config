local auto_session = require 'auto-session'

auto_session.setup({
  log_level = "error",
  auto_session_use_git_branch = true,
  auto_save_enabled = true
})
