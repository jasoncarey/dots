return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tailwindcss = {
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern(
              "tailwind.config.js",
              "tailwind.config.ts",
              "tailwind.config.cjs",
              "tailwind.config.mjs"
            )(fname)
          end,
        },
        vtsls = {
          settings = {
            typescript = {
              tsserver = { maxTsServerMemory = 2048 },
            },
          },
        },
      },
    },
  },
}