require "mini.surround".setup()
require "mini.indentscope".setup()
require "mini.icons".setup()
require "mini.move".setup()
require "mini.cursorword".setup()
require "mini.tabline".setup()
require "mini.splitjoin".setup()
require "mini.operators".setup {
  evaluate = { prefix = "", },
  sort = { prefix = "", },
}

local hipatterns = require "mini.hipatterns"
-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-hipatterns.md#example-usage
hipatterns.setup {
  highlighters = {
    fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme", },
    hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack", },
    todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo", },
    note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote", },
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
}

local pick = require "mini.pick"
local fuzzy = require "mini.fuzzy"

local h = require "helpers"
local mini_icons = require "mini.icons"
local frecency_helpers = require "fzf-lua-frecency.helpers"
local frecency_fs = require "fzf-lua-frecency.fs"
local frecency_algo = require "fzf-lua-frecency.algo"


vim.keymap.set("n", "<leader>f", function()
  local fd_files = {}
  local frecency_files = {}
  local open_buffers = {}

  local function populate_caches()
    local fd_cmd = "fd --absolute-path --hidden --type f --exclude node_modules --exclude .git --exclude dist"
    local fd_handle = io.popen(fd_cmd)
    if fd_handle then
      for fd_file in fd_handle:lines() do
        local icon_ok, icon_res = pcall(mini_icons.get, "file", fd_file)
        local icon = icon_ok and icon_res or "?"
        local formatted = icon .. " |" .. fd_file

        table.insert(fd_files, formatted)
      end
      fd_handle:close()
    end

    local cwd = vim.fn.getcwd()
    local bufs = vim.fn.getbufinfo { buflisted = h.vimscript_true, }
    for _, buf in pairs(bufs) do
      if not vim.startswith(buf.name, cwd) then goto continue end
      if buf.loaded == h.vimscript_false then goto continue end
      if buf.name == nil then goto continue end
      if buf.name == "" then goto continue end

      open_buffers[buf.name] = 0

      ::continue::
    end

    local now = os.time()
    local sorted_files_path = frecency_helpers.get_sorted_files_path()
    local dated_files_path = frecency_helpers.get_dated_files_path()
    local dated_files = frecency_fs.read(dated_files_path)

    for frecency_file in io.lines(sorted_files_path) do
      if vim.fn.filereadable(frecency_file) == 0 then goto continue end
      if not vim.startswith(frecency_file, cwd) then goto continue end

      local db_index = 1
      if not dated_files[db_index] then
        dated_files[db_index] = {}
      end
      local date_at_score_one = dated_files[db_index][frecency_file]
      local score = frecency_algo.compute_score { now = now, date_at_score_one = date_at_score_one, }

      frecency_files[frecency_file] = score

      ::continue::
    end
  end

  --- @class SortStrItemsOpts
  --- @field stritems string[]
  --- @field query table
  --- @field type "sort" | "populate"

  --- @param opts SortStrItemsOpts
  local function sort_stritems(opts)
    local querytick = pick.get_querytick()

    local OPEN_BUF_BOOST = 10
    local CHANGED_BUF_BOOST = 20
    local CURR_BUF_BOOST = -1000
    local MAX_FUZZY_SCORE = 10100
    local MAX_FRECENCY_SCORE = 100

    local function scale_fuzzy_value_to_frecency(value)
      return (value) / (MAX_FUZZY_SCORE) * MAX_FRECENCY_SCORE
    end

    local curr_buf = vim.fn.expand "#:p"
    local cwd = vim.fn.getcwd()

    local query = table.concat(opts.query)
    query = query:gsub("%s+", "") -- mini.fuzzy doesn't ignore spaces

    --- @param cb function
    local function process_scored_items(cb)
      local scored_items = {}
      for idx, stritem in ipairs(opts.stritems) do
        local should_stop = not pick.poke_is_picker_active() or pick.get_querytick() ~= querytick
        if should_stop then return end

        local file = vim.split(stritem, "|")[2]
        local score = 0


        if open_buffers[file] ~= nil then
          local bufnr = vim.fn.bufnr(file)
          local changed = vim.fn.getbufinfo(bufnr)[1].changed

          if file == curr_buf then
            score = CURR_BUF_BOOST
          elseif changed == h.vimscript_true then
            score = CHANGED_BUF_BOOST
          else
            score = OPEN_BUF_BOOST
          end
        end

        if frecency_files[file] ~= nil then
          score = score + frecency_files[file]
        end

        local rel_file = vim.fs.relpath(cwd, file)
        if query ~= "" then
          local fuzzy_score = fuzzy.match(query, rel_file).score
          if fuzzy_score == -1 then goto continue end
          local inverted_fuzzy_score = MAX_FUZZY_SCORE - fuzzy_score
          local scaled_fuzzy_score = scale_fuzzy_value_to_frecency(inverted_fuzzy_score)

          -- h.dev.log {
          --   query = query,
          --   fuzzy_score = fuzzy_score,
          --   inverted_fuzzy_score = inverted_fuzzy_score,
          --   scaled_fuzzy_score = scaled_fuzzy_score,
          --   rel_file = rel_file,
          -- }

          score = 0.7 * scaled_fuzzy_score + 0.3 * score
          ::continue::
        end

        table.insert(scored_items, { stritem = rel_file, score = score, idx = idx, })
      end

      cb(scored_items)
    end

    if opts.type == "sort" then
      coroutine.resume(coroutine.create(function()
        process_scored_items(function(scored_items)
          table.sort(scored_items, function(a, b)
            return a.score > b.score
          end)
          local sorted_indexes = vim.tbl_map(function(item) return item.idx end, scored_items)
          pick.set_picker_match_inds(sorted_indexes)
        end)
      end
      ))
    else
      coroutine.resume(coroutine.create(function()
        process_scored_items(function(scored_items)
          local formatted_items = vim.tbl_map(function(item)
            local icon_ok, icon_res = pcall(mini_icons.get, "file", item.stritem)
            local icon = icon_ok and icon_res or "?"
            local formatted = icon .. " |" .. item.stritem
            return formatted
          end, scored_items)
          pick.set_picker_items(formatted_items)
        end)
      end
      ))
    end
  end

  local function items()
    populate_caches()
    return sort_stritems { stritems = fd_files, query = {}, type = "populate", }
  end

  local function match(stritems, _, query)
    return sort_stritems { stritems = stritems, query = query, type = "sort", }
  end

  pick.start {
    source = {
      name = "Smart files",
      items = items,
      match = match,
    },
    window = {
      config = {
        anchor = "NW",
        row = vim.o.lines,
        col = 0,
        width = vim.o.columns,
        height = math.floor(0.4 * vim.o.lines),
      },
    },
  }
end)
