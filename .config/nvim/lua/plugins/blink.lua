return {
	"saghen/blink.cmp",
	version = "1.*", -- release tag ships a prebuilt fuzzy-matcher binary (no cargo needed)
	opts = {
		keymap = { preset = "super-tab" },
		completion = {
			-- Auto-show the docs popup on selection so import paths / sources are visible
			documentation = { auto_show = true, auto_show_delay_ms = 200 },
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},
	},
}
