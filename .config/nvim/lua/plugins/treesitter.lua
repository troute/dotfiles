return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master", -- pin explicitly; the default branch is now the unstable `main` rewrite
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"lua",
				"javascript",
				"typescript",
				"tsx",
				"html",
				"css",
				"python",
				"markdown",
				"markdown_inline",
			},
			highlight = {
				enable = true,
			},
		})
	end,
}
