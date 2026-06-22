return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		opts = {},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"pyright",
					"ruff",
					"ts_ls",
					"eslint",
					"html",
					"cssls",
					"tailwindcss",
					"jsonls",
					"lua_ls",
				},
				-- Servers are enabled explicitly via vim.lsp.enable below (single source of truth)
				automatic_enable = false,
			})
		end,
		dependencies = {
			"williamboman/mason.nvim",
		},
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			-- Configure diagnostics
			vim.diagnostic.config({
				virtual_text = {
					spacing = 2,
					prefix = "●",
					format = function(diagnostic)
						return string.format("[%s] %s", diagnostic.source, diagnostic.message)
					end,
				},
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "!!",
						[vim.diagnostic.severity.WARN] = " !",
						[vim.diagnostic.severity.HINT] = "󰋼",
						[vim.diagnostic.severity.INFO] = "i",
					},
				},
				underline = true,
				update_in_insert = false,
				severity_sort = true,
				float = {
					border = "rounded",
					source = "always",
					header = "",
					prefix = "",
				},
			})

			-- Global LSP config (applies to all servers)
			vim.lsp.config("*", {
				capabilities = require("blink.cmp").get_lsp_capabilities(),
			})

			-- Server-specific configs
			vim.lsp.config("pyright", {
				settings = {
					pyright = {
						disableOrganizeImports = true, -- Use Ruff for this
					},
					python = {
						analysis = {
							typeCheckingMode = "basic",
							useLibraryCodeForTypes = true,
							diagnosticSeverityOverrides = {
								reportGeneralTypeIssues = "warning",
								reportOptionalMemberAccess = "warning",
								reportOptionalSubscript = "warning",
								reportPrivateImportUsage = "none",
								reportUnboundVariable = "none",
							},
						},
					},
				},
			})

			vim.lsp.config("ruff", {
				init_options = {
					settings = {
						run = "onSave",
						logLevel = "warn",
					},
				},
			})

			-- Enable all servers (mason-lspconfig handles this via automatic_enable)
			vim.lsp.enable({
				"pyright",
				"ruff",
				"ts_ls",
				"html",
				"cssls",
				"tailwindcss",
				"eslint",
				"jsonls",
				"lua_ls",
			})

			-- Global mappings
			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
			vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic details" })
			vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Add diagnostics to location list" })

			-- Use LspAttach autocommand to only map the following keys
			-- after the language server attaches to the current buffer
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					local opts = { buffer = ev.buf }
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
					vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
					vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
				end,
			})
		end,
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"saghen/blink.cmp",
		},
	},
}
