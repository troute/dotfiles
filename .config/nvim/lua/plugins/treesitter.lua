-- nvim-treesitter `main` branch (the rewrite), required for Neovim 0.11+/0.12.
-- The legacy `master` branch is frozen and its queries error on 0.12.
local ensure_installed = {
	"lua",
	"javascript",
	"typescript",
	"tsx",
	"html",
	"css",
	"python",
	"markdown",
	"markdown_inline",
}

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").install(ensure_installed)

		-- On `main`, highlighting is started per buffer rather than via a module.
		-- Resolve the language from the filetype so injected-only parsers
		-- (markdown_inline) and aliased filetypes (tsx -> typescriptreact) work.
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
				if not lang then
					return
				end
				local ok, added = pcall(vim.treesitter.language.add, lang)
				if ok and added then
					vim.treesitter.start(args.buf, lang)
				end
			end,
		})
	end,
}
