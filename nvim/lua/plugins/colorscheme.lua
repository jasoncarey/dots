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
        hl.DiffChange = { bg = "#1f2335" }
        hl.DiffText = { bg = "#24283b" }
        hl.DiffDelete = { bg = "#1f2335", fg = "#f7768e" }
        hl.DiffDeleteSign = { fg = "#f7768e", bg = "NONE" }
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
