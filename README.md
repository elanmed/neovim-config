# neovim config

- A minimal(ish) config written in lua, uses:

  - [coc](https://github.com/neoclide/coc.nvim) for completions/linting
  - treesitter for [t/jsx commenting](https://github.com/JoosepAlviste/nvim-ts-context-commentstring) and
    [t/jsx pair renaming](https://github.com/windwp/nvim-ts-autotag)
  - [leap](https://github.com/ggandor/leap.nvim), [clever-f](https://github.com/rhysd/clever-f.vim) and
    [easymotion](https://github.com/easymotion/vim-easymotion) for quicker movements
  - [vim tmux navigator](https://github.com/christoomey/vim-tmux-navigator) for moving between vim and tmux panes
  - [bqf](https://github.com/kevinhwang91/nvim-bqf) for a better quick-fix list
  - [telescope](https://github.com/nvim-telescope/telescope.nvim)
  - [oil](https://github.com/stevearc/oil.nvim) for a better netrw
  - [bufferline](https://github.com/akinsho/bufferline.nvim) for buffer management

---

- Uses a unique project structure that supports:
  1. A barebones config that requires no external dependencies
  2. An IDE-like config with plugins managed by [packer](https://github.com/wbthomason/packer.nvim)
     - The default when running `nvim`
  3. Options, remaps, and utilities shared between the two

```
├── coc-settings.json
├── init.lua
├── lua
│   ├── barebones
│   │   ├── init.lua
│   │   ├── options.lua
│   │   └── remaps.lua
│   ├── settings
│   │   ├── functions.lua
│   │   ├── options.lua
│   │   ├── plugins
│   │   │   ├── [plugin_name].lua
│   │   │   ├── init.lua
│   │   │   ├── packer.lua
│   │   └── remaps.lua
│   ├── shared
│   │   ├── helpers.lua
│   │   ├── options.lua
│   │   └── remaps.lua
│   └── telescope
│       └── _extensions
│           └── rg_with_args.lua
```

To run the barebones config:

```bash
nvim -u ~/.config/nvim/lua/barebones/init.lua
```
