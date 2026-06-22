return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		{
			"<leader>f",
			function()
				require("fzf-lua").files()
			end,
			desc = "Find files",
		},
		{
			"<leader>F",
			function()
				require("fzf-lua").files({ hidden = true })
			end,
			desc = "Find files (incl. hidden)",
		},
		{
			"<leader>g",
			function()
				require("fzf-lua").live_grep()
			end,
			desc = "Live grep",
		},
	},
	config = function()
		local fzf = require("fzf-lua")
		fzf.setup({ "telescope" })
		fzf.register_ui_select()
	end,
}
