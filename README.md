# neovim config

- a minimal(ish) config written entirely in lua. uses:

  - [coc](https://github.com/neoclide/coc.nvim) for completions/linting
  - treesitter for [t/jsx commenting](https://github.com/JoosepAlviste/nvim-ts-context-commentstring) and [t/jsx pair renaming](https://github.com/windwp/nvim-ts-autotag)
  - [lightspeed](https://github.com/ggandor/lightspeed.nvim) and [easymotion](https://github.com/easymotion/vim-easymotion) for quicker movements
  - [vim tmux navigator](https://github.com/christoomey/vim-tmux-navigator) for moving seemlessly between vim and tmux panes
  - [bqf](https://github.com/kevinhwang91/nvim-bqf) for a better quick-fix window
  - [telescope](https://github.com/nvim-telescope/telescope.nvim) with a custom [plugin](https://github.com/ElanMedoff/neovim-config/blob/master/lua/telescope/_extensions/rg_with_args.lua) for an opinionated but cleaner global search interface
  - [nvim tree](https://github.com/nvim-tree/nvim-tree.lua) for a better file tree than netrw
  - [bufferline](https://github.com/akinsho/bufferline.nvim) for a buffers-as-tabs replacement

- if it's a default, I try not to include it in my config
- in its own repo so I can easily pull changes across my different computers/servers

---

To bootstrap with external dependencies, run:

```bash
chmod +x bootstrap.sh # make script executable
./bootstrap.sh
```

To run a barebones config with no dependencies, run:

```bash
nvim -u ~/.config/nvim/lua/barebones/init.lua
```

or create an alias

```bash
alias nvim="nvim -u ~/.config/nvim/lua/barebones/init.lua"
```
