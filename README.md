# neovim config

- A minimalish config written in lua, uses:

  - [lspconfig](https://github.com/neovim/nvim-lspconfig) for language server features
  - [cmp](https://github.com/hrsh7th/nvim-cmp) for completions
  - [treesitter](https://github.com/nvim-treesitter/nvim-treesitter) for syntax highlighting, fancy pair renaming
  - [flash](https://github.com/folke/flash.nvim) for a combo of [easymotion](https://github.com/easymotion/vim-easymotion) and [leap](https://github.com/ggandor/leap.nvim)
  - [vim tmux navigator](https://github.com/christoomey/vim-tmux-navigator) for moving between vim and tmux panes
  - [fzf-lua](https://github.com/ibhagwan/fzf-lua) as a picker
  - [grug-far](https://github.com/MagicDuck/grug-far.nvim) for an interative global find and replace interface
  - [bufferline](https://github.com/akinsho/bufferline.nvim) for buffer management
  - [fugitive](https://github.com/tpope/vim-fugitive), [diffview](https://github.com/sindrets/diffview.nvim) and [gitsigns](https://github.com/lewis6991/gitsigns.nvim) for git integration
  - [oil](https://github.com/stevearc/oil.nvim) for a better netrw
  - [wilder](https://github.com/gelguy/wilder.nvim) for a better wild menu

---

- Uses a unique project structure that supports:
  1. A barebones config that requires no external dependencies
  2. An feature-complete config with plugins managed by [plug](https://github.com/junegunn/vim-plug)
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
│   │       ├── [plugin_name].lua
│   ├── shared
│   │   ├── helpers.lua
│   │   ├── options.lua
│   │   ├── homegrown_plugins.lua
│   │   ├── remaps.lua
│   │   └── user_commands.lua
```

To run the feature-complete config, use `nvim`

To run the barebones config:

```bash
nvim -u ~/.config/nvim/barebones.lua
```
