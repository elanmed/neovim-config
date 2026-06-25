local start = "^"
local capture_rest = "(.+)"
local skip_digits = "%d+"
local optional_comma = ",?"
local optional_digits = "%d*"
local optional_count = "(" .. optional_comma .. optional_digits .. ")"
local capture_digits = "(%d+)"
local any_remaining = "(.*)"

local file_header_pattern = start .. "%+%+%+ b/" .. capture_rest
local hunk_header_pattern = start ..
    "@@ %-" .. skip_digits .. optional_count .. " %+" .. capture_digits .. optional_count .. " @@ ?" .. any_remaining

local function get_tracked_hunks()
  local diff_output = vim.fn.systemlist "git diff HEAD --unified=0"
  local current_file = nil
  local hunks = {}
  for _, line in ipairs(diff_output) do
    local file = line:match(file_header_pattern)
    if file ~= nil then
      current_file = file
    end
    local lnum, context = line:match(hunk_header_pattern)
    if lnum ~= nil and current_file ~= nil then
      table.insert(hunks, ("%s|%s|1|%s"):format(current_file, lnum, context))
    end
  end
  return hunks
end

local function get_untracked_entries()
  return vim.tbl_map(function(untracked_file)
    return ("%s|1|1|untracked"):format(untracked_file)
  end, vim.fn.systemlist "git ls-files --others --exclude-standard")
end

for _, entry in ipairs(vim.list_extend(get_tracked_hunks(), get_untracked_entries())) do
  io.write(entry .. "\n")
end
