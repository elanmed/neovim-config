# neovim config

- A minimalish config written in lua, uses:

  - [coc](https://github.com/neoclide/coc.nvim) for completions/linting
  - treesitter for [t/jsx commenting](https://github.com/JoosepAlviste/nvim-ts-context-commentstring) and
    [t/jsx pair renaming](https://github.com/windwp/nvim-ts-autotag)
  - [leap](https://github.com/ggandor/leap.nvim), [flit](https://github.com/ggandor/flit.nvim) and
    [easymotion](https://github.com/easymotion/vim-easymotion) for quicker movements
  - [vim tmux navigator](https://github.com/christoomey/vim-tmux-navigator) for moving between vim and tmux panes
  - [bqf](https://github.com/kevinhwang91/nvim-bqf) for a better quick-fix list
  - [telescope](https://github.com/nvim-telescope/telescope.nvim)
  - [oil](https://github.com/stevearc/oil.nvim) for a better netrw
  - [bufferline](https://github.com/akinsho/bufferline.nvim) for buffer management
  - [fugitive](https://github.com/tpope/vim-fugitive) and [gitsigns](https://github.com/lewis6991/gitsigns.nvim) for git
    integration

---

- Uses a unique project structure that supports:
  1. A barebones config that requires no external dependencies
  2. An feature-complete config with plugins managed by [packer](https://github.com/wbthomason/packer.nvim)
  3. Options, remaps, and utilities shared between the two

```
├── +barebones.lua
├── +feature_complete.lua
├── coc-settings.json
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
│   │   └── remaps.lua
```

To run the feature-complete config:

```bash
nvim -u ~/.config/nvim/+feature_complete.lua
```

To run the barebones config:

```bash
nvim -u ~/.config/nvim/+barebones.lua
```
