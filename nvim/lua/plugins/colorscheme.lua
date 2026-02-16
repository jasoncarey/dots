return {
  { "navarasu/onedark.nvim", priority = 1000 },
  { "rebelot/kanagawa.nvim", priority = 1000 },
  { "rose-pine/neovim", name = "rose-pine", priority = 1000 },
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("solarized-osaka").setup({
        styles = {
          floats = "transparent",
        },
      })
    end,
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },

      on_highlights = function(hl, c)
        hl.DiffDelete = { bg = "#2a2e36", fg = "#565f89" }
        hl.DiffChange = { bg = "#2a2e36" }
        hl.DiffText = { bg = "#3a3f4b" }
        hl.DiffAdd = { bg = "#233027" }
      end,
    },
  },
  { "tiagovla/tokyodark.nvim", priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
