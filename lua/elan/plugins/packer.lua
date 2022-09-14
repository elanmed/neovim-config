local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
		vim.cmd([[packadd packer.nvim]])
		return true
	end
	return false
end

local packer_bootstrap = ensure_packer()

-- reloads neovim whenever you save the file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost /Users/elanmedoff/.config/nvim/lua/elan/plugins/packer.lua source <afile> | PackerSync
  augroup end
]])

-- use a protected call so we don't error out on first use
local packer = require("packer")

return packer.startup({
	function(use)
		use("wbthomason/packer.nvim")
		use("nvim-lua/popup.nvim") -- an implementation of the Popup API from vim in Neovim
		use("nvim-lua/plenary.nvim") -- lua functions used in lots of plugins

		-- misc
		use("akinsho/toggleterm.nvim")
		use("tpope/vim-surround")
		use("ggandor/lightspeed.nvim")
		use("nvim-lualine/lualine.nvim")
		use("easymotion/vim-easymotion")
		use("psliwka/vim-smoothie")
		use({ "kevinhwang91/nvim-bqf", ft = "qf" })
		use("romgrk/barbar.nvim")
		use("mg979/vim-visual-multi")
		use({
			"iamcco/markdown-preview.nvim",
			run = "cd app && npm install",
			setup = function()
				vim.g.mkdp_filetypes = { "markdown" }
			end,
			ft = { "markdown" },
		})
		use({
			"neoclide/coc.nvim",
			branch = "release",
		})
		use("jose-elias-alvarez/null-ls.nvim")
		use("lukas-reineke/indent-blankline.nvim")
		use("tpope/vim-repeat")
		use("ThePrimeagen/harpoon")
		use("goolord/alpha-nvim")
		use({
			"AckslD/nvim-neoclip.lua",
			requires = {
				-- you'll need at least one of these
				{ "nvim-telescope/telescope.nvim" },
				{ "ibhagwan/fzf-lua" },
			},
			config = function()
				require("neoclip").setup({})
			end,
		})

		-- themes
		use("ElanMedoff/vscode.nvim")
		use("ElanMedoff/tokyonight.nvim")
		use("Everblush/everblush.nvim")

		-- fzf
		use({ "junegunn/fzf", run = "./install --bin" })
		use("ibhagwan/fzf-lua")

		-- git
		use("lewis6991/gitsigns.nvim")
		use("tpope/vim-fugitive")

		-- https://github.com/sindrets/diffview.nvim/commit/c244577dd425072275eff925e87739820ac5e0aa
		use({ "sindrets/diffview.nvim", commit = "a2945c82a58f23fba15c1b5319642fd6b2666df7" })

		-- tree
		use("kyazdani42/nvim-web-devicons")
		use("kyazdani42/nvim-tree.lua")

		-- treesitter
		use({
			"nvim-treesitter/nvim-treesitter",
			run = ":TSUpdate",
		})
		use("p00f/nvim-ts-rainbow")
		use("windwp/nvim-ts-autotag")

		-- commenting
		use("numToStr/Comment.nvim")
		use("JoosepAlviste/nvim-ts-context-commentstring")

		if packer_bootstrap then
			require("packer").sync()
		end
	end,
	config = {
		display = {
			open_fn = require("packer.util").float,
		},
	},
})
