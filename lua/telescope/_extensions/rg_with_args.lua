local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local config = require "telescope.config"
local config_values = config.values
local make_entry = require "telescope.make_entry"
local fns = require "shared/helpers"


local rg_with_args = function(opts)
  opts = opts or {}
  opts.vimgrep_arguments = opts.vimgrep_arguments or config_values.vimgrep_arguments
  opts.entry_maker = opts.entry_maker or make_entry.gen_from_vimgrep(opts)

  local function cmd_generator(prompt)
    local args = fns.tbl_clone(opts.vimgrep_arguments)
    if not prompt or prompt == "" then
      return nil
    end

    local term_and_files = fns.split(prompt, "?")
    local term = fns.trim(term_and_files[1])

    if fns.len(term_and_files) == 1 then
      print(table.concat(vim.tbl_flatten { args, term }, " "))
      return vim.tbl_flatten { args, term }
    end

    local files = term_and_files[2]

    local files_split = fns.split(files, ",")
    local rg_cmd = { term }

    for index, file in pairs(files_split) do
      local trimmed = fns.trim(file)
      -- ignore split items that are empty strings, after being trimmed
      if trimmed == '' then
        goto continue
      end

      -- only insert into the table when the search is finished, i.e. , or space
      if index == fns.len(files_split) then
        -- check before trimming
        if string.sub(files, -1) ~= " " and string.sub(files, -1) ~= "," then
          break
        end
      end

      table.insert(rg_cmd, "-g")
      table.insert(rg_cmd, trimmed)

      ::continue::
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

local function rg_under_cursor()
  local word_under_cursor = vim.fn.expand("<cword>")
  rg_with_args({ default_text = word_under_cursor .. ' ? ' })
end

local function rg_visual_selection()
  local visual = fns.get_visual()
  local text = visual[1] or ""
  rg_with_args({ default_text = text .. ' ? ' })
end

return require("telescope").register_extension({
  exports = {
    rg_with_args = rg_with_args,
    rg_under_cursor = rg_under_cursor,
    rg_visual_selection = rg_visual_selection,
  },
})
