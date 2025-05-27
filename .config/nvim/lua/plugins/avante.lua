return {
	"yetone/avante.nvim",
	event = "VeryLazy",
	version = "*",
	opts = {
		provider = "claude",
		claude = {
			endpoint = "https://api.anthropic.com",
			model = "claude-3-7-sonnet-latest",
			timeout = 30000,
			temperature = 0,
			max_tokens = 4096,
		},
	},
	build = "make",
	behaviour = {
		enable_claude_text_editor_tool_mode = true,
	},
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"stevearc/dressing.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		--- The below dependencies are optional,
		"nvim-telescope/telescope.nvim",
		"hrsh7th/nvim-cmp",
		"nvim-tree/nvim-web-devicons",
		{
			-- support for image pasting
			"HakonHarnes/img-clip.nvim",
			event = "VeryLazy",
			opts = {
				-- recommended settings
				default = {
					embed_image_as_base64 = false,
					prompt_for_file_name = false,
					drag_and_drop = {
						insert_mode = true,
					},
				},
			},
		},
		{
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				file_types = { "markdown", "Avante" },
			},
			ft = { "markdown", "Avante" },
		},
	},
}
