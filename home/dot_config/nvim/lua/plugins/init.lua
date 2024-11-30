return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "williamboman/mason.nvim",
    opts = {
      automatic_installation = true,
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = require "configs.nvim-treesitter",
  },
}
