return {
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {} -- this uses the default configuration
  },
  {
    'windwp/nvim-ts-autotag',
    event = "InsertEnter",
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = function()
        require('nvim-ts-autotag').setup()
    end
  }
}
