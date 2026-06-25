local tracked_output = vim.fn.systemlist "git diff HEAD --unified=0"

local current_file = nil
for _, line in ipairs(tracked_output) do
  local file = line:match "^%+%+%+ b/(.+)"
  if file then
    current_file = file
  end

  local lnum, context = line:match "^@@ %-%d+,?%d* %+(%d+),?%d* @@ ?(.*)"
  if lnum and current_file then
    io.write(("%s|%s|1|%s\n"):format(current_file, lnum, context))
  end
end

local untracked_files = vim.fn.systemlist "git ls-files --others --exclude-standard"
for _, untracked_file in ipairs(untracked_files) do
  io.write(("%s|1|1|untracked\n"):format(untracked_file))
end
