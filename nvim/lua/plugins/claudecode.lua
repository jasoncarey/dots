local toggle_key = "<F5>"
-- local toggle_key = "<F13>" -- swap to this once VIA is set up

return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  keys = {
    { toggle_key, "<cmd>ClaudeCodeFocus<cr>", desc = "Toggle Claude Code", mode = { "n", "x" } },
  },
  opts = {
    terminal = {
      snacks_win_opts = {
        position = "float",
        width = 0.6,
        height = 0.7,
        border = "rounded",
        keys = {
          claude_hide = {
            toggle_key,
            function(self)
              self:hide()
            end,
            mode = "t",
            desc = "Hide Claude Code",
          },
        },
      },
    },
    diff_opts = {
      open_in_new_tab = true,
      hide_terminal_in_new_tab = true,
    },
  },
  config = true,
}
