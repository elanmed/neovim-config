-- https://github.com/wbthomason/packer.nvim#bootstrapping
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
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
  pattern = "/Users/elanmedoff/.config/nvim/lua/settings/plugins/packer.lua",
  command = "source <afile> | PackerSync"
})

local ok, packer = pcall(require, "packer")
if not ok then
  return
end

return packer.startup(({
  function(use)
    use "wbthomason/packer.nvim"

    use "nvim-lua/popup.nvim"
    use "nvim-lua/plenary.nvim" -- lua functions used in lots of plugins

    -- misc
    use "tpope/vim-surround"
    use "tpope/vim-repeat"
    use "ggandor/leap.nvim"
    use "nvim-lualine/lualine.nvim"
    use "easymotion/vim-easymotion"
    use "psliwka/vim-smoothie"
    use "ThePrimeagen/harpoon"
    use "Xuyuanp/scrollbar.nvim"
    use "christoomey/vim-tmux-navigator"
    use({
      "neoclide/coc.nvim",
      branch = "release",
    })
    use "mg979/vim-visual-multi"
    use({
      "iamcco/markdown-preview.nvim",
      run = "cd app && npm install",
      ft = { "markdown" },
    })
    -- use({
    --   'ckolkey/ts-node-action',
    --   requires = { 'nvim-treesitter' },
    -- })
    use "HiPhish/rainbow-delimiters.nvim"

    -- buffers as tabs
    use "akinsho/bufferline.nvim"
    use "RRethy/nvim-base16"
    use "moll/vim-bbye"
    use "vim-scripts/BufOnly.vim"

    -- bqf
    use "kevinhwang91/nvim-bqf"
    use({ "junegunn/fzf", run = "./install --bin", }) -- for fuzzy searching within a list

    -- telescope
    use({
      "nvim-telescope/telescope.nvim", branch = "0.1.x",
    })
    use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
    use "AckslD/nvim-neoclip.lua"

    -- git
    use "tpope/vim-fugitive"
    -- https://github.com/sindrets/diffview.nvim/commit/c244577dd425072275eff925e87739820ac5e0aa
    use({ "sindrets/diffview.nvim", commit = "a45163cb9ee65742cf26b940c2b24cc652f295c9" })

    -- file tree
    use "kyazdani42/nvim-web-devicons"
    use "kyazdani42/nvim-tree.lua"

    use({
      "nvim-treesitter/nvim-treesitter",
      -- https://github.com/rafamadriz/dotfiles/commit/c1268c73bdc7da52af0d57dcbca196ca3cb5ed79
      run = function() require("nvim-treesitter.install").update() end,
      requires = {
        "windwp/nvim-ts-autotag",
        "JoosepAlviste/nvim-ts-context-commentstring",
        "lukas-reineke/indent-blankline.nvim",
        "numToStr/Comment.nvim"
      }
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
