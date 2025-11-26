return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = {},
        nil_ls = {
          enabled = not on_windows,
          nix = {
            flake = {
              autoArchive = true,
            },
          },
        },
      },
    },
  },
}
