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
        hl.DiffAdd = { bg = "#1f3b2c" }
        hl.DiffChange = { bg = "#2e3f66" }
        hl.DiffText = { bg = "#3d5a98", bold = true }
        hl.DiffDelete = { bg = "#3b1f25", fg = "#a05060" }
        hl.DiffDeleteSign = { fg = "#a05060", bg = "NONE" }
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
