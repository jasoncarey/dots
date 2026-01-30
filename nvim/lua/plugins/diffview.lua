return {
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },

    -- Make sure the plugin autoloads when these commands are used
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },

    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diffview: open" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: file history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: repo history" },
    },

    opts = {
      view = {
        default = {
          layout = "diff2_horizontal", -- side-by-side
        },
      },
    },
  },
}
