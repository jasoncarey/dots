return {
  {
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",

    keys = {
      { "<leader>gc", "<cmd>CodeDiff<cr>", desc = "CodeDiff: open" },
      { "<leader>gC", "<cmd>CodeDiff main...<cr>", desc = "CodeDiff: vs main" },
      { "<leader>gf", "<cmd>CodeDiff file HEAD<cr>", desc = "CodeDiff: file vs HEAD" },
      { "<leader>gm", "<cmd>CodeDiff merge<cr>", desc = "CodeDiff: merge" },
    },

    opts = {
      diff = {
        layout = "side-by-side",
      },
    },
  },
}