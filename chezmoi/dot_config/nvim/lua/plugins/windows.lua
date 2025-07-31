local windows = vim.fn.has("win32") == 1

if windows then
  return {
    -- Disable chezmoi plugins on Windows (not compatible)
    { "xvzc/chezmoi.nvim", enabled = false },
    { "alker0/chezmoi.vim", enabled = false },
    -- Disable nil_ls language server on Windows (requires VC++ linker)
    {
      "neovim/nvim-lspconfig",
      opts = {
        servers = {
          nil_ls = { enabled = false },
        },
      },
    },
    {
      "stevearc/conform.nvim",
      opts = {
        formatters_by_ft = {
          nix = {},
        },
      },
    },
  }
else
  return {}
end
