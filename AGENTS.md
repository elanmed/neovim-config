# AGENTS.md

## Template plugin

`PLAN.md` defers to the `elanmed/template.nvim` template plugin for testing standards. Before writing or reworking tests, shallow-clone it and read its principles:

```bash
git clone --depth 1 https://github.com/elanmed/template.nvim /tmp/template.nvim
```

Read `/tmp/template.nvim/PRINCIPLES.md` in full and use it to judge which principles apply to this Neovim config and its tests. Re-use an existing clone rather than re-cloning.

## Test layout

- One test file per config source file: replace `/` with `_` in the source path, drop `.lua`, append `_test.lua` (`lua/shared/options.lua` -> `tests/lua_shared_options_test.lua`).
- `scripts/minimal_init.lua` collects both `tests/**/test_*.lua` and `tests/**/*_test.lua`, so no registration is needed for new files.
- Mirror the source module in the test file: one top-level set per function named `M.fn()`, behavior-sentence case names ("aborts for readonly buffers").
- Every case must exercise observable behavior (buffer contents, files on disk, notifications, cursor, register state). No placeholder or dummy-equality smoke tests.
- State that a case touches (buffers, cwd, registers, stubs, highlight groups, mappings) must be restored with `MiniTest.finally`, so the whole suite can run in one Neovim process.

## Helpers

Put reusable fixtures and expectations in `tests/_helpers.lua`; do not define them locally in individual test files. Some examples available today:

- `mock(target, overrides)` -> recorded `{ name, args }` calls; restores the originals automatically.
- `expect_buffer_lines(buf_id, lines)` and `expect_cursor(win_id, position)` -> custom `MiniTest.new_expectation` expectations.
- `make_temp_dir()` -> created dir, deleted afterwards.
- `chdir_to_sandbox()` -> temp dir that is also the cwd, cwd restored afterwards.
- `open_file_buffer(lines)` -> path of a written file opened in the current window; buffer wiped afterwards.
- `open_scratch_buffer(lines, cursor)` -> scratch buffer id made current; buffer deleted afterwards.
- `file_contains(path, line)` -> whether the file holds `line` (whitespace runs collapsed).
- `with_saved_registers(callback)` -> runs the callback, then restores registers `0`-`9` and the unnamed register.
- `write_temp_file(contents)` -> path of a written temp file.

## Test principles

- Prefer helpers that return a value over helpers that take a callback: callers should keep a flat case body (`local sandbox_dir = test_helpers.chdir_to_sandbox()`). Take a callback only when the helper must bracket the work, like `with_saved_registers`.
- Add a custom expectation instead of repeating a raw API call plus `expect.equality` (`nvim_buf_get_lines`, `nvim_win_get_cursor`), and give it a failure message that shows the observed and the expected value.
- Assert single values with plain `expect.equality`. Do not build compared tables with `vim.tbl_map` or other indirection; write out each expected value, even when it means eight consecutive `expect.equality` calls.
- Name constants instead of hardcoding magic numbers: `vim.log.levels.WARN` / `vim.log.levels.INFO`, not `3` / `2`.
- Stub via `test_helpers.mock`, assert the recorded calls as a full literal list (`{ { name = "notify", args = { "Aborting, readonly", vim.log.levels.WARN } } }`). Do not hand-roll `rawset` plus manual restore.
- Assert command output files with readable literal lines (`test_helpers.file_contains(path, "n gzq * <Cmd>echo 1<CR>")`), not with Lua patterns that encode column padding.
- Only assert on output the code under test controls. Vim's builtin `:hi`/`:map` dumps are long and ordered by Vim's defaults, so an index-based assertion would test Vim, not this config.
- Prefer deterministic fixtures over stubs of the filesystem: real temp dirs and files, and stubbed externals at the boundary (cwd, `stdpath`, `notify`, clipboard registers).

## Verification

Before calling the work done, run all of these:

- `make test`
- `make lint`
- `make format`
