return {
  {
    "TheLeoP/powershell.nvim",
    ---@module 'powershell'
    ---@type powershell.user_config
    opts = {
      bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services",
    },
    ft = "ps1",
  },
}
