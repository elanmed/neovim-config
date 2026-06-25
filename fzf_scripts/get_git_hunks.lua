local function run_cmd(cmd_parts)
  return vim.split(vim.system(cmd_parts):wait().stdout, "\n", { trimempty = true, })
end

local changed_files = run_cmd { "git", "diff", "HEAD", "--name-only", }

for _, filepath in ipairs(changed_files) do
  local head_lines = run_cmd { "git", "show", ("HEAD:%s"):format(filepath), }
  local working_lines = vim.fn.readfile(filepath)

  local head_string = table.concat(head_lines, "\n") .. "\n"
  local working_string = table.concat(working_lines, "\n") .. "\n"

  vim.text.diff(head_string, working_string, {
    on_hunk = function(_, _, start_b, _)
      if start_b == 0 then return end
      local content = working_lines[start_b]
      io.write(("%s|%s|1|%s\n"):format(filepath, start_b, content))
    end,
  })
end

local untracked_files = run_cmd { "git", "ls-files", "--others", "--exclude-standard", }
for _, untracked_file in ipairs(untracked_files) do
  io.write(("%s|1|1|untracked\n"):format(untracked_file))
end
