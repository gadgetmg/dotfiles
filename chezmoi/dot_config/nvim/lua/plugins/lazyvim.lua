return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },

  -- default plugins to disable
  { "akinsho/bufferline.nvim", enabled = false },
  { "folke/noice.nvim", enabled = false },
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },
  {
    "xvzc/chezmoi.nvim",
    opts = {
      edit = {
        watch = true,
        force = true,
      },
      notification = {
        on_open = true,
        on_apply = true,
        on_watch = true,
      },
    },
  },
}
