-- return {
--   {
--     "coder/claudecode.nvim",
--     dependencies = { "folke/snacks.nvim" },
--     keys = {
--       { "<leader>ac", "<cmd>ClaudeCodeFocus<cr>", desc = "Claude Code", mode = { "n", "x" } },
--       -- make <leader>ac work inside the floating terminal too
--       {
--         "<leader>ac",
--         [[<C-\><C-n><cmd>ClaudeCodeFocus<cr>]],
--         desc = "Claude Code",
--         mode = "t",
--       },
--     },
--     opts = {
--       terminal = {
--         snacks_win_opts = {
--           position = "float",
--           width = 0.6,
--           height = 0.6,
--           border = "double",
--           backdrop = 80,
--         },
--       },
--     },
--   },
-- }

-- config for left side chat
return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  opts = {
    terminal = {
      split_side = "left",
      split_width_percentage = 0.30,
    },
  },
  config = true,
}
