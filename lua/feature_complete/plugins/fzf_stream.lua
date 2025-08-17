local FzfStream = {}
FzfStream.__index = FzfStream

function FzfStream.new()
  local self = setmetatable({}, FzfStream)
  self.content_file = vim.fn.tempname()
  self.done_file = self.content_file .. ".done"
  self.partial_file = self.content_file .. ".partial"

  vim.fn.delete(self.content_file)
  vim.fn.delete(self.done_file)
  vim.fn.delete(self.partial_file)
  vim.fn.writefile({}, self.content_file)

  return self
end

function FzfStream:create_monitor_cmd()
  return string.format(
    "while [[ ! -f %s ]]; do cat %s; sleep 0.3; done; cat %s",
    self.done_file, self.content_file, self.content_file
  )
end

function FzfStream:update_results(source)
  if source then
    local curr_content = vim.fn.readfile(self.content_file)
    local updated_content = vim.list_extend(curr_content, { source, })

    vim.fn.writefile(updated_content, self.partial_file)
    -- avoids partial reads by cat
    vim.fn.rename(self.partial_file, self.content_file)
  else
    vim.fn.writefile({}, self.done_file)
  end
end

return FzfStream
