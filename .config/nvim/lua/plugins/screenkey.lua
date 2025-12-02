return {
	"NStefan002/screenkey.nvim",
	lazy = false,
	version = "*",
	config = function()
		require("screenkey").setup({
			clear_after = 2,
			win_opts = {
				border = "rounded",
				title = "Keys",
			},
		})
		vim.schedule(function()
			require("screenkey").toggle()
		end)
	end,
	keys = {
		{ "<leader>k", "<cmd>Screenkey toggle<CR>", desc = "Toggle Screenkey" },
	},
}
