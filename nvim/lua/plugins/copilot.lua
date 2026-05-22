return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      panel = { enabled = false },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = false,
          accept_word = false,
          accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      filetypes = {
        markdown = true,
        gitcommit = true,
        ["*"] = true,
      },
    },
  },
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        ["<Tab>"] = {
          function()
            local ok, sug = pcall(require, "copilot.suggestion")
            if ok and sug.is_visible() then
              sug.accept()
              return true
            end
          end,
          "select_next",
          "snippet_forward",
          "fallback",
        },
      },
    },
  },
}

