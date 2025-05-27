return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = {
		{ "<leader>f", ":Telescope find_files<CR>" },
		{ "<leader>F", ":Telescope find_files hidden=true<CR>" },
		{ "<leader>g", ":Telescope live_grep<CR>" },
	},
}
