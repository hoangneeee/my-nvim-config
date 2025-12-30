-- Tokyonight colorscheme configuration (LazyVim default)

return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night", -- night, storm, day, moon
      transparent = false,
      styles = {
        sidebars = "dark",
        floats = "dark",
      },
    },
  },
}
