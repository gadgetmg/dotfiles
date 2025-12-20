return {
  {
    "swaits/zellij-nav.nvim",
    lazy = true,
    event = "VeryLazy",
    keys = {
      { "<M-h>", "<cmd>ZellijNavigateLeftTab<cr>", { silent = true, desc = "navigate left or tab" } },
      { "<M-j>", "<cmd>ZellijNavigateDown<cr>", { silent = true, desc = "navigate down" } },
      { "<M-k>", "<cmd>ZellijNavigateUp<cr>", { silent = true, desc = "navigate up" } },
      { "<M-l>", "<cmd>ZellijNavigateRightTab<cr>", { silent = true, desc = "navigate right or tab" } },
    },
    opts = {},
  },
}
