return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require("neo-tree").setup({
			close_if_last_window = true,
			filesystem = {
				follow_current_file = {
					enabled = true,
				},
			},
			buffers = {
				follow_current_file = {
					enabled = true,
				},
			},
		})
	end,
	keys = {
		{ "<leader>t", ":Neotree toggle position=left<CR>" },
		{ "<leader>T", ":Neotree float<CR>" },
	},
}
