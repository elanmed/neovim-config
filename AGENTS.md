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
- In an in-process case, everything it touches (cwd, registers, stubs, highlight groups, mappings) must be restored with `MiniTest.finally`; in a child case, the per-case `child.restart` is the cleanup.
- Anything that runs inside Vim (buffers, windows, options, `_G` functions, autocommands, screen state) is tested in a child Neovim, not in the test process: `MiniTest.new_child_neovim()` with `child.restart { "-u", "scripts/minimal_init.lua" }` in `pre_case` and `post_once = child.stop`. The child is thrown away after every case, so global state cannot leak and no restore code is needed. Reserve the in-process style for pure Lua logic (string/table helpers, data transforms) that never touches Vim state.
- Child-side Lua: use `child.lua`/`child.lua_get` for a single expression, and `child.lua_func` whenever the code is more than one line. Functions handed to `child.lua_func` are dumped, so they must not capture upvalues — pass data as arguments and return one structured value.

## Helpers

Put reusable fixtures and expectations in `tests/_helpers.lua`; do not define them locally in individual test files. If a test helper would only be used by one test file, do not put it in `tests/_helpers.lua`. When you add a helper, re-read every other test file and adopt it wherever it now fits. A helper used only once is not a helper: inline it at the call site instead of naming it.

## Test principles

- Prefer helpers that return a value over helpers that take a callback: callers should keep a flat case body (`local sandbox_dir = test_helpers.chdir_to_sandbox()`). Take a callback only when the helper must bracket the work, like `with_saved_registers`.
- Add a custom expectation instead of repeating a raw API call plus `expect.equality` (`nvim_buf_get_lines`, `nvim_win_get_cursor`), and give it a failure message that shows the observed and the expected value.
- Mapping is fine when the value under test is itself a table (`expect.equality(vim.tbl_map(function(list_arg) return list_arg.title end, result), { "second" })`) and when it collapses genuinely repetitive access, such as the numbered registers (`vim.tbl_map(function(index_arg) return vim.fn.getreginfo(tostring(index_arg)).regcontents[1] end, { 1, 2, 3, 4, 5, 6, 7, 8, 9 })`). Do not map just to save a line or two when the asserted values are distinct; write those out as separate `expect.equality` calls.
- Name constants instead of hardcoding magic numbers: `vim.log.levels.WARN` / `vim.log.levels.INFO`, not `3` / `2`.
- Stubs go through `test_helpers.mock`, asserting the recorded calls as a full literal list (`{ { name = "notify", args = { "Aborting, readonly", vim.log.levels.WARN } } }`). Function arguments are recorded as `"<function>"` so recorded calls stay comparable and RPC-serializable. `mock` restores the originals after an in-process case; inside a child call `test_helpers.mock_child(target, overrides, store_name)`, which records the same way but leaves the stubs in place, since the process is thrown away; pass `store_name` (e.g. `"notifications"`) to publish the recorded calls on `_G[store_name]` for the parent to assert with `child.lua_get`. Do not hand-roll `rawset` or manual restore.
- Assert command output files with readable literal lines (`test_helpers.file_contains(path, "n gzq * <Cmd>echo 1<CR>")`), not with Lua patterns that encode column padding.
- Only assert on output the code under test controls. Vim's builtin `:hi`/`:map` dumps are long and ordered by Vim's defaults, so an index-based assertion would test Vim, not this config.
- When adding tests, look for bugs in the code under test and flag them to the user (with the case that reveals them) instead of silently encoding the current behavior as correct, and record each one in `BUGS.md` (code reference, surprising behavior, and the test case that pins it down).
- Prefer deterministic fixtures over stubs of the filesystem: real temp dirs and files, and stubbed externals at the boundary (cwd, `stdpath`, `notify`, clipboard registers).

## Verification

Before calling the work done, run all of these:

- `make test`
- `make lint`
- `make format`
