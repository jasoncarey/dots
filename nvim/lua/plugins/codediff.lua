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
      explorer = {
        width = 50,
      },
    },

    config = function(_, opts)
      require("codediff").setup(opts)

      vim.api.nvim_create_autocmd("User", {
        pattern = "CodeDiffVirtualFileLoaded",
        callback = function(args)
          local buf = args.data and args.data.buf
          if not buf or not vim.api.nvim_buf_is_valid(buf) then
            return
          end
          vim.bo[buf].modifiable = true
          vim.bo[buf].readonly = false
          vim.b[buf].codediff_user_edited = false

          vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
            buffer = buf,
            callback = function()
              vim.b[buf].codediff_user_edited = true
            end,
          })
        end,
      })

      local auto_refresh = require("codediff.ui.auto_refresh")
      local original_sync = auto_refresh.sync_mutable_buffers
      auto_refresh.sync_mutable_buffers = function(tabpage)
        local lifecycle = require("codediff.ui.lifecycle")
        local orig_buf, mod_buf = lifecycle.get_buffers(tabpage)
        for _, b in ipairs({ orig_buf, mod_buf }) do
          if b and vim.api.nvim_buf_is_valid(b) and vim.b[b].codediff_user_edited then
            return
          end
        end
        return original_sync(tabpage)
      end
    end,
  },
}

