# AGENTS.md

Conventions live in skills - load all Neovim related skills.

## Test layout

- One test file per config source file: replace `/` with `_` in the source path, drop `.lua`, append `_test.lua` (`lua/shared/options.lua` -> `tests/lua_shared_options_test.lua`).
- `scripts/minimal_init.lua` collects both `tests/**/test_*.lua` and `tests/**/*_test.lua`, so no registration is needed for new files.

## Verification

Before calling the work done, run all of these:

- `make test`
- `make lint`
- `make format`
