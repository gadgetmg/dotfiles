return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = {
          cmd_env = {
            DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = true,
          },
        },
        nil_ls = { enabled = false },
        nixd = {
          settings = {
            nixd = {
              nixpkgs = {
                expr = "let hosts = (builtins.getFlake (builtins.toString ./.)).nixosConfigurations; in (builtins.foldl' (acc: name: acc // (builtins.getAttr name hosts)) {} (builtins.attrNames hosts)).pkgs",
              },
              options = {
                nixos = {
                  expr = "let hosts = (builtins.getFlake (builtins.toString ./.)).nixosConfigurations; in (builtins.foldl' (acc: name: acc // (builtins.getAttr name hosts)) {} (builtins.attrNames hosts)).options",
                },
                flake = {
                  expr = "(builtins.getFlake (builtins.toString ./.)).debug.options",
                },
                perSystem = {
                  expr = "(builtins.getFlake (builtins.toString ./.)).currentSystem.options",
                },
              },
            },
          },
        },
        jsonnet_ls = {
          cmd = { "jsonnet-language-server", "-t" },
        },
      },
    },
  },
}
