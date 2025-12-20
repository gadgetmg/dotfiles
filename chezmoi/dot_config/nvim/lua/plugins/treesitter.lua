return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "jsonnet" },
      incremental_selection = {
        keymaps = {
          init_selection = "<CR>",
          node_incremental = "<CR>",
        },
      },
      indent = {
        disable = { "yaml" },
      },
    },
  },
}
