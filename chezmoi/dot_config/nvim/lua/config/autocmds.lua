-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Override lazyvim_wrap_spell to include org files
vim.api.nvim_create_autocmd("FileType", {
  group = "lazyvim_wrap_spell",
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown", "org" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})
