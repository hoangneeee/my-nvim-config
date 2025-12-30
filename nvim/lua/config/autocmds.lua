-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local autocmd = vim.api.nvim_create_autocmd

-- Example: Highlight on yank
autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Example: Auto-format on save for specific filetypes
-- autocmd("BufWritePre", {
--   pattern = { "*.lua", "*.py", "*.js", "*.ts" },
--   callback = function()
--     vim.lsp.buf.format({ async = false })
--   end,
-- })
