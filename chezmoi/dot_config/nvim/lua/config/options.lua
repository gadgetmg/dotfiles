-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local windows = vim.fn.has("win32") == 1

vim.g.snacks_animate = false

if windows then
  -- needed for orgmode on Windows
  vim.opt.shellslash = true
end
