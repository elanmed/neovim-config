# `nvim` config

- A minimalish config written in lua, uses:
  - `vim.pack` as a package manager
  - [lspconfig](https://github.com/neovim/nvim-lspconfig) for pre-built language server configs
    - Uses a small bash script to install language servers
  - [fzf](https://github.com/junegunn/fzf/blob/master/README-VIM.md) as a primary picker
    - Populated by custom lua scripts that are executed by `fzf` in headless `nvim` instances (see blog [post](https://elanmed.dev/blog/native-fzf-in-neovim))
  - My own plugins:
    - [ff](https://github.com/elanmed/ff.nvim)
    - [rg-far](https://github.com/elanmed/rg-far.nvim)
    - [tree](https://github.com/elanmed/tree.nvim)
    - [surround](https://github.com/elanmed/surround.nvim)
    - [seek](https://github.com/elanmed/seek.nvim)
    - [marks](https://github.com/elanmed/marks.nvim)
    - [ft-highlight](https://github.com/elanmed/ft-highlight.nvim)
    - [quickfix-preview](https://github.com/elanmed/quickfix-preview.nvim)
  - [mini.icons](https://github.com/nvim-mini/mini.icons) and [mini.splitjoint](https://github.com/nvim-mini/mini.splitjoin)

---

- Uses a unique project structure that supports:
  - A barebones config that requires no external dependencies
  - A feature-complete config with external plugins, treesitter parsers, and language servers
  - Options, remaps, and utilities shared between the two

```
├── barebones.lua
├── feature_complete.lua
├── init.lua -> feature_complete.lua (symlink)
├── lua
│   ├── barebones
│   │   └── init.lua
│   ├── feature_complete
│   │   ├── init.lua
│   │   └── plugins
│   │       └── [plugin_name].lua
│   ├── shared
│   │   └── ...
```

To run the feature-complete config, use `nvim`

To run the barebones config:

```bash
nvim -u ~/.config/nvim/barebones.lua
```
