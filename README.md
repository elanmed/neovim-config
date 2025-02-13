# neovim config

- A minimalish config written in lua, uses:

  - [lspconfig](https://github.com/neovim/nvim-lspconfig), [mason](https://github.com/williamboman/mason.nvim) for language server features
  - [cmp](https://github.com/hrsh7th/nvim-cmp) for completions
  - [treesitter](https://github.com/nvim-treesitter/nvim-treesitter) for syntax highlighting, pair renaming, and viewing a file's code structure
  - [flash](https://github.com/folke/flash.nvim) for a combo of [easymotion](https://github.com/easymotion/vim-easymotion), [flit](https://github.com/ggandor/flit.nvim), and [leap](https://github.com/ggandor/leap.nvim)
  - [vim tmux navigator](https://github.com/christoomey/vim-tmux-navigator) for moving between vim and tmux panes
  - [harpoon](https://github.com/ThePrimeagen/harpoon/tree/harpoon2) for moving between frequently-used files
  - [telescope](https://github.com/nvim-telescope/telescope.nvim) to find anything that can be found in a single search
  - [grug-far](https://github.com/MagicDuck/grug-far.nvim) to find/replace anything that needs multiple searches with refinements
  - [bufferline](https://github.com/akinsho/bufferline.nvim) for buffer management
  - [fugitive](https://github.com/tpope/vim-fugitive) and [gitsigns](https://github.com/lewis6991/gitsigns.nvim) for git integration
  - [oil](https://github.com/stevearc/oil.nvim) for a better netrw
  - [bqf](https://github.com/kevinhwang91/nvim-bqf) for a better quick-fix list
  - [wilder](https://github.com/gelguy/wilder.nvim) for a better wild menu

---

- Uses a unique project structure that supports:
  1. A barebones config that requires no external dependencies
  2. An feature-complete config with plugins managed by [plug](https://github.com/junegunn/vim-plug)
  3. Options, remaps, and utilities shared between the two

```
├── barebones.lua
├── coc-settings.json
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
│   │   ├── remapse.lua
│   │   └── user_commands.lua
```

To run the feature-complete config, use `nvim`

To run the barebones config:

```bash
nvim -u ~/.config/nvim/barebones.lua
```
