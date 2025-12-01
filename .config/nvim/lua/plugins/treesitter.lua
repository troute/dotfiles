return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"lua",
				"javascript",
				"typescript",
				"tsx",
				"html",
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
