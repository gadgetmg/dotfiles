return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = {
          cmd_env = {
            DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = true,
          }
        },
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
