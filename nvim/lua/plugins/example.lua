-- Custom plugin configurations
-- Add your custom plugins here or override LazyVim defaults

return {
  -- Ensure rust-analyzer is installed via Mason
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "rust-analyzer",
      },
    },
  },
}
