return {
	"lewis6991/gitsigns.nvim",

	-- Load when opening a buffer instead of during startup
	event = "BufReadPre",

	opts = {
		signs = {
			-- These are the default symbols, but explicitly configured
			add = { text = "│" }, -- New lines
			change = { text = "│" }, -- Modified lines
			delete = { text = "_" }, -- Deleted lines (shown where they were)
			topdelete = { text = "‾" }, -- Deleted lines (shown above deletion)
			changedelete = { text = "~" }, -- Changed then deleted
			untracked = { text = "┆" }, -- Untracked files
		},

		-- Highlight line numbers
		numhl = true,

		-- Show blame on current line
		current_line_blame = true,
	},
}
