-- Custom plugin configurations
-- Add your custom plugins here or override LazyVim defaults

return {
  -- Neo-tree configuration (disabled)
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
  },

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
