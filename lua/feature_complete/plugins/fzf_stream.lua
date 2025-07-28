local FzfStream = {}
FzfStream.__index = FzfStream

function FzfStream.new()
  local self = setmetatable({}, FzfStream)
  self.temp_file = vim.fn.tempname()
  self.done_file = self.temp_file .. ".done"

  vim.fn.delete(self.temp_file)
  vim.fn.delete(self.done_file)

  vim.fn.writefile({}, self.temp_file)

  return self
end

function FzfStream:create_monitor_cmd()
  return string.format(
    "while [[ ! -f %s ]]; do cat %s; sleep 0.2; done; cat %s",
    self.done_file, self.temp_file, self.temp_file
  )
end

function FzfStream:update_results(source)
  vim.fn.writefile(source, self.temp_file)
  vim.fn.writefile({}, self.done_file)
end

return FzfStream
