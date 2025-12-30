-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

-- Your custom options (override LazyVim defaults)
opt.relativenumber = true
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Tabs
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true

-- Undo
opt.undofile = true
opt.undolevels = 10000
