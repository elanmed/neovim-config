local h = require "shared.helpers"

-- https://github.com/wbthomason/packer.nvim#bootstrapping
local function ensure_packer()
  local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
    vim.cmd("packadd packer.nvim")
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- reloads neovim whenever you save the file
vim.api.nvim_create_augroup("PackerGroup", {})
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  group = "PackerGroup",
  pattern = (h.is_mac() and "/Users/elanmedoff" or "/home/elan") ..
      "/.dotfiles/neovim/.config/nvim/lua/feature_complete/packer.lua",
  command = "source <afile> | PackerSync"
})

local ok, packer = pcall(require, "packer")
if not ok then
  return
end

return packer.startup(({
  function(use)
    use({ "wbthomason/packer.nvim" })
    use({ "nvim-lua/popup.nvim" })
    use({ "nvim-lua/plenary.nvim" })

    -- tpope
    use({ "tpope/vim-surround" })
    use({ "tpope/vim-repeat" })
    use({ "tpope/vim-speeddating" })

    use({ "mg979/vim-visual-multi", commit = "38b0e8d" })
    use({ "windwp/nvim-autopairs", commit = "19606af" })
    use({ "stevearc/aerial.nvim", commit = "92f93f4" })
    use({ "neoclide/coc.nvim", branch = "release", commit = "ae1a557" })

    -- visuals
    use({ "nvim-lualine/lualine.nvim", commit = "b431d22" })
    use({ "echasnovski/mini.map", commit = "8baf542" })
    use({ "folke/zen-mode.nvim", commit = "29b292b" })
    use({ "karb94/neoscroll.nvim", commit = "532dcc8" })

    -- movements
    use({ "ggandor/leap.nvim", commit = "c6bfb19" })
    use({ "easymotion/vim-easymotion", commit = "b3cfab2" })
    use({ "ggandor/flit.nvim", commit = "1ef72de" })
    use({ "chentoast/marks.nvim", commit = "74e8d01" })
    use({ "christoomey/vim-tmux-navigator", commit = "5b3c701" })
    use({
      "ThePrimeagen/harpoon",
      branch = "harpoon2",
      commit = "0378a6c"
    })

    -- buffers as tabs
    use({ "akinsho/bufferline.nvim", commit = "0b2fd86" })
    use({ "RRethy/nvim-base16", commit = "6ac181b" })
    -- use({ "vim-scripts/BufOnly.vim", commit = "43dd923" })
    use({ "numtostr/BufOnly.nvim", cmd = "BufOnly", commit = "30579c2" })

    -- bqf
    use({ "kevinhwang91/nvim-bqf", commit = "1b24dc6" })
    use({ "junegunn/fzf", run = "./install --bin", commit = "a09c6e9" })

    -- telescope
    use({ "nvim-telescope/telescope.nvim", commit = "a0bbec2" })
    use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make", commit = "cf48d4d" })
    use({ "AckslD/nvim-neoclip.lua", commit = "709c97f" })
    use({ "fannheyward/telescope-coc.nvim", commit = "b305a2c" })
    -- use( {  "nvim-telescope/telescope-frecency.nvim" } )

    -- git
    use({ "lewis6991/gitsigns.nvim", commit = "899e993" })
    use({ "tpope/vim-fugitive" })

    -- file tree
    use({ "kyazdani42/nvim-web-devicons", commit = "3722e3d" })
    use({ "stevearc/oil.nvim", commit = "30e0438" })
    use({ "preservim/nerdtree", commit = "9b465ac" })

    -- treesitter
    use({
      "nvim-treesitter/nvim-treesitter",
      -- https://github.com/rafamadriz/dotfiles/commit/c1268c73bdc7da52af0d57dcbca196ca3cb5ed79
      run = function() require("nvim-treesitter.install").update() end,
      commit = "7a64148",
      requires = {
        { "windwp/nvim-ts-autotag",                      commit = "e239a56" },
        { "JoosepAlviste/nvim-ts-context-commentstring", commit = "375c2d8" },
        { "lukas-reineke/indent-blankline.nvim",         commit = "db92699" },
        { "numToStr/Comment.nvim",                       commit = "e30b7f2" },
        { "RRethy/nvim-treesitter-endwise",              commit = "8b34305" },
      }
    })
    use({
      "MeanderingProgrammer/markdown.nvim",
      as = "render-markdown",
      after = { "nvim-treesitter" },
      commit = "8c67dbc",
      config = function()
        require("render-markdown").setup({})
      end,
    })

    if packer_bootstrap then
      require("packer").sync()
    end
  end,
  config = {
    display = {
      open_fn = require("packer.util").float,
    },
  },
}))
