return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.sections.lualine_b = opts.sections.lualine_b or {}

      table.insert(opts.sections.lualine_b, 1, {
        function()
          return vim.g.worktree_label and ("WT:" .. vim.g.worktree_label) or ""
        end,
      })
    end,
  },
}
