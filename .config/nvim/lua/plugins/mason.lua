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
          "ts_ls",
          "eslint",
          "html",
          "cssls",
          "tailwindcss",
          "jsonls",
          "lua_ls",
        },
      })
    end,
    dependencies = {
      "williamboman/mason.nvim",
    }
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- LSP Configuration
      local lspconfig = require("lspconfig")
      
      local signs = {
        Error = "!!",  -- x circle
        Warn = " !",   -- exclamation circle
        Hint = "󰋼",   -- bookmark
        Info = "i"    -- info circle
      }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      -- Configure diagnostics
      vim.diagnostic.config({
        -- Configure error message
        virtual_text = {
          spacing = 2,
          prefix = '●',
          format = function(diagnostic)  -- custom formatting
            return string.format('[%s] %s', diagnostic.source, diagnostic.message)
          end,
        },
        signs = true,
        underline = true,         -- Underline the text with an error
        update_in_insert = false, -- Don't update diagnostics in insert mode
        severity_sort = true,     -- Sort diagnostics by severity
        float = {
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })

      -- Setup pyright
      lspconfig.pyright.setup({
        filetype = { 'python' },
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "workspace",
              useLibraryCodeForTypes = true,
            },
          },
        },
      })

      -- Setup TypeScript
      lspconfig.ts_ls.setup({
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      -- Setup HTML
      lspconfig.html.setup({
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      -- Setup CSS
      lspconfig.cssls.setup({
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      -- Setup Tailwind CSS
      lspconfig.tailwindcss.setup({
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      -- Setup ESLint
      lspconfig.eslint.setup({
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      -- Setup JSON
      lspconfig.jsonls.setup({
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
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

      -- Enable formatting on save
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.css", "*.json", "*.html" },
        callback = function()
          vim.lsp.buf.format()
        end,
      })
    end,
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",  -- Add this dependency for better completion support
    }
  },
}
