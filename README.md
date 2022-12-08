# neovim config

- a minimal(ish) config written entirely in lua. uses [coc](https://github.com/neoclide/coc.nvim) for completions/linting, built-in treesitter support for proper [t/jsx commenting](https://github.com/JoosepAlviste/nvim-ts-context-commentstring) and [t/jsx pair renaming](https://github.com/windwp/nvim-ts-autotag)
- if it's a default, I try not to include it in my config
- heavily inspired by [this repo](https://github.com/LunarVim/Neovim-from-scratch)
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

<!--
todo:
- folding the level below where you fold
-->
