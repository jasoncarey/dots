return {
  {
    "shortcuts/no-neck-pain.nvim",
    version = "*",
    keys = {
      { "<leader>z", "<cmd>NoNeckPain<cr>", desc = "No Neck Pain (toggle)" },
    },
    opts = {
      width = 140,
      minSideBufferWidth = 8,
      autocmds = {
        enableOnVimEnter = false,
        reloadOnColorSchemeChange = true,
        skipEnteringNoNeckPainBuffer = true,
      },
    },
  },
}
