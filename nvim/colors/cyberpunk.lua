local theme = require("config.cyberpunk.config")

require("tokyonight").setup({
  style = "moon",
  transparent = true,
  styles = {
    comments = {},
    keywords = {},
    functions = {},
    variables = {},
    sidebars = "dark",
    floats = "transparent",
  },
  on_colors = function(colors)
    theme.apply_colors(colors)
  end,
  on_highlights = function(highlights, colors)
    theme.apply_highlight(highlights, colors)
  end,
  cache = false,
  plugins = { auto = true },
})

require("tokyonight").load()
vim.g.colors_name = "cyberpunk"