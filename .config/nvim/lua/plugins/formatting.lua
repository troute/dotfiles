return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "mason.nvim",
  },
  config = function()
    local null_ls = require("null-ls")
    
    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.prettier
      }
    })

    -- Enable formatting on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.css", "*.json", "*.html" },
      callback = function()
        vim.lsp.buf.format()
      end,
    })
  end,
}
