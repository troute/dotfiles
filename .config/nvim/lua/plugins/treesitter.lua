return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function ()
    require('nvim-treesitter.configs').setup({
      ensure_installed = {
        "lua",
        "javascript",
        "typescript",
        "tsx",
        "html",
        "python",
      },
      highlight = {
        enable = true,
      },
    })
  end
}
