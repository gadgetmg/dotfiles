return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        yaml = { "yamlfmt" },
        nix = not on_windows and { "alejandra" } or {},
        hcl = { "hcl" },
      },
    },
  },
}
