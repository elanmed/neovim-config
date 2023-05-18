local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local config = require "telescope.config"
local config_values = config.values
local make_entry = require "telescope.make_entry"

local function dump(o)
  if type(o) == "table" then
    local s = "{ "
    for k, v in pairs(o) do
      if type(k) ~= "number" then k = '"' .. k .. '"' end
      s = s .. "[" .. k .. "] = " .. dump(v)
    end
    return s .. "} "
  else
    return tostring(o)
  end
end

local function split(self, sSeparator, nMax, bRegexp)
  assert(sSeparator ~= "")
  assert(nMax == nil or nMax >= 1)

  local aRecord = {}

  if self:len() > 0 then
    local bPlain = not bRegexp
    nMax = nMax or -1

    local nField, nStart = 1, 1
    local nFirst, nLast = self:find(sSeparator, nStart, bPlain)
    while nFirst and nMax ~= 0 do
      aRecord[nField] = self:sub(nStart, nFirst - 1)
      nField = nField + 1
      nStart = nLast + 1
      nFirst, nLast = self:find(sSeparator, nStart, bPlain)
      nMax = nMax - 1
    end
    aRecord[nField] = self:sub(nStart)
  end

  return aRecord
end

local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function len(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

local tbl_clone = function(original)
  local copy = {}
  for key, value in pairs(original) do
    copy[key] = value
  end
  return copy
end

local rg_with_args = function(opts)
  opts = opts or {}
  opts.vimgrep_arguments = opts.vimgrep_arguments or config_values.vimgrep_arguments
  opts.entry_maker = opts.entry_maker or make_entry.gen_from_vimgrep(opts)

  local function cmd_generator(prompt)
    local args = tbl_clone(opts.vimgrep_arguments)
    if not prompt or prompt == "" then
      return nil
    end

    local term_and_files = split(prompt, "?")
    local term = trim(term_and_files[1])

    if len(term_and_files) == 1 then
      print(table.concat(vim.tbl_flatten { args, term }, " "))
      return vim.tbl_flatten { args, term }
    end

    local files = term_and_files[2]

    local files_split = split(files, ",")
    local rg_cmd = { term }

    for index, file in pairs(files_split) do
      -- hack for continue
      repeat
        if index == len(files_split) then
          if string.sub(file, -1) ~= " " then
            -- continue
            do break end
          end
        end

        local trimmed = trim(file)
        table.insert(rg_cmd, "-g")
        table.insert(rg_cmd, trimmed)
      until true
    end


    print(table.concat(vim.tbl_flatten { args, rg_cmd }, " "))
    return vim.tbl_flatten { args, rg_cmd }
  end


  pickers.new(opts, {
    prompt_title = "Prompt",
    finder = finders.new_job(cmd_generator, opts.entry_maker),
    previewer = config_values.grep_previewer(opts),
  }):find()
end

return require("telescope").register_extension({
  exports = {
    rg_with_args = rg_with_args
  },
})
