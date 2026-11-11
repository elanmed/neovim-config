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

## Verification

Before calling the work done, run all of these:

- `make test`
- `make lint`
- `make format`
