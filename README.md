# `nvim` config

- A minimalish config written in lua, uses:
  - `vim.pack` as a package manager
  - [lspconfig](https://github.com/neovim/nvim-lspconfig) for pre-built language server configs
    - Uses a small ruby script to install language servers
  - [flash](https://github.com/folke/flash.nvim) for a combo of [easymotion](https://github.com/easymotion/vim-easymotion) and [leap](https://github.com/ggandor/leap.nvim)
  - [fzf](https://github.com/junegunn/fzf/blob/master/README-VIM.md) as a primary picker
    - Populated by custom lua scripts that are executed by `fzf` in headless `nvim` instances (see blog [post](https://elanmed.dev/blog/native-fzf-in-neovim))
    - [rg-glob-builder](https://github.com/elanmed/rg-glob-builder.nvim) for searching with `rg`
  - [ff](https://github.com/elanmed/ff.nvim) as a fuzzy file finder
  - [tree](https://github.com/elanmed/tree.nvim) as a file tree
  - [grug-far](https://github.com/MagicDuck/grug-far.nvim) for an interative global find and replace
  - [quickfix-preview](https://github.com/elanmed/quickfix-preview.nvim)
  - Most of the [mini](https://github.com/echasnovski/mini.nvim) plugins

---

- Uses a unique project structure that supports:
  1. A barebones config that requires no external dependencies
  2. An feature-complete config with plugins managed by paq
  3. Options, remaps, and utilities shared between the two

```
├── barebones.lua
├── feature_complete.lua
├── init.lua -> feature_complete.lua (symlink)
├── lua
│   ├── barebones
│   │   └── init.lua
│   ├── feature_complete
│   │   ├── init.lua
│   │   └── plugins
│   │       └── [plugin_name].lua
│   ├── shared
│   │   └── ...
```

To run the feature-complete config, use `nvim`

To run the barebones config:

```bash
nvim -u ~/.config/nvim/barebones.lua
```
