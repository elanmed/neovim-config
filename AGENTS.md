# AGENTS.md

Testing preferences and principles live in the `testing-neovim-plugins` skill; read it before writing or reworking tests.

## Template plugin

`PLAN.md` defers to the `elanmed/template.nvim` template plugin for testing standards. Before writing or reworking tests, shallow-clone it and read its principles:

```bash
git clone --depth 1 https://github.com/elanmed/template.nvim /tmp/template.nvim
```

Read `/tmp/template.nvim/PRINCIPLES.md` in full and use it to judge which principles apply to this Neovim config and its tests. Re-use an existing clone rather than re-cloning.

## Test layout

- One test file per config source file: replace `/` with `_` in the source path, drop `.lua`, append `_test.lua` (`lua/shared/options.lua` -> `tests/lua_shared_options_test.lua`).
- `scripts/minimal_init.lua` collects both `tests/**/test_*.lua` and `tests/**/*_test.lua`, so no registration is needed for new files.
- Potential bugs found while writing tests are recorded in `BUGS.md` (code reference, surprising behavior, and the test case that pins it down).

## Lua style

Prefer an immediately invoked function expression over the ternary-style `cond and a or b`, which silently drops a falsy `a` and hides multi-step branches:

```lua
local bufnr = (function()
  if item_arg.path == nil then
    return nil
  end

  return vim.fn.bufadd(item_arg.path)
end)()
```

## Neovim APIs

Prefer the native Lua implementation over its `vim.fn` binding: it skips the Vimscript bridge and carries types. Use `vim.trim`, `vim.split`, `vim.fs.*`, `vim.text.*`, and `vim.api.*`; reach for `vim.fn.*` only when there is no Lua equivalent, or when the Vimscript version does more (`vim.fn.trim` also trims a list).

```lua
local text = vim.trim(item.text)
```

## Type annotations

Every function parameter carries a `--- @param` type comment, including anonymous callbacks and `child.lua_func` closures. Name parameters with an `_arg` suffix when the callback would shadow an outer name.

Two exceptions stay unannotated, because their signatures are dictated by MiniTest or by the API being faked:

- the predicate and failure-context functions of `MiniTest.new_expectation`;
- the override functions inside a `mock`/`mock_child` table.

```lua
--- @param items QuickfixTestItem[]
--- @param idx integer?
local set_qf_list = function(items, idx)
  child.lua_func(
    --- @param items_arg QuickfixTestItem[]
    --- @param idx_arg integer
    function(items_arg, idx_arg)
      -- ...
    end,
    items,
    idx or 1
  )
end
```

Prefer a named class over a bare `table` parameter, declaring it next to its first use and marking fields that fixtures may omit as optional:

```lua
--- @class QuickfixTestItem
--- @field path string?
--- @field lnum integer?
```

## Verification

Before calling the work done, run all of these:

- `make test`
- `make lint`
- `make format`
