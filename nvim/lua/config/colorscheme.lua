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
    opts = function(_, opts)
      opts.style = "night"
      opts.transparent = true
      opts.styles = vim.tbl_deep_extend("force", opts.styles or {}, {
        sidebars = "transparent",
        floats = "transparent",
      })

      opts.on_highlights = function(hl, c)
        hl.Normal = { bg = "NONE" }
        hl.NormalFloat = { bg = "NONE" }
        hl.SignColumn = { bg = "NONE" }
        hl.EndOfBuffer = { bg = "NONE" }
      end
    end,
  },
  { "tiagovla/tokyodark.nvim", priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
