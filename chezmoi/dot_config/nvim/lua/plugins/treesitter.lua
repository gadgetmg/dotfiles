return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
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
