-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.cmd.colorscheme(vim.g.colors_name)

-- local function set_diff_hls()
--   local bg = "#2a2e36"
--   local fg = "#565f89"
--
--   vim.api.nvim_set_hl(0, "DiffDelete", { bg = bg, fg = fg })
--   vim.api.nvim_set_hl(0, "DiffChange", { bg = bg })
--   vim.api.nvim_set_hl(0, "DiffText", { bg = "#3a3f4b" })
--   vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#233027" })
-- end
--
-- -- when colorscheme is applied
-- vim.api.nvim_create_autocmd("ColorScheme", {
--   pattern = "*",
--   callback = function()
--     vim.schedule(set_diff_hls)
--   end,
-- })
--
-- local function fix_diff()
--   vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#2a2e36", fg = "#565f89" })
--   vim.api.nvim_set_hl(0, "DiffChange", { bg = "#2a2e36" })
--   vim.api.nvim_set_hl(0, "DiffText", { bg = "#3a3f4b" })
--   vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#233027" })
-- end
--
-- local grp = vim.api.nvim_create_augroup("FixDiffHighlights", { clear = true })
--
-- -- Run when themes change
-- vim.api.nvim_create_autocmd("ColorScheme", {
--   group = grp,
--   callback = function()
--     vim.schedule(fix_diff)
--   end,
-- })
--
-- -- Run on common “something just reset highlights” moments
-- vim.api.nvim_create_autocmd({ "VimEnter", "UIEnter", "BufEnter", "WinEnter" }, {
--   group = grp,
--   callback = function()
--     -- schedule so we run after whatever triggered this event
--     vim.schedule(fix_diff)
--   end,
-- })
--
-- -- And a “late final” pass (covers async theme/plugin setup)
-- vim.api.nvim_create_autocmd("VimEnter", {
--   group = grp,
--   once = true,
--   callback = function()
--     vim.defer_fn(fix_diff, 1500)
--   end,
-- })

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    -- vim.schedule(set_diff_hls)
    vim.g.worktree_label = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    local root = vim.fn.getcwd()

    -- change this to match your project folder name or marker file
    if vim.fn.filereadable(root .. "/biome.json") == 1 or vim.fn.filereadable(root .. "/package.json") == 1 then
      vim.api.nvim_buf_create_user_command(0, "Fix", function()
        vim.cmd("write")
        vim.fn.jobstart("yarn lint:fix", {
          stdout_buffered = true,
          stderr_buffered = true,
          on_exit = function()
            vim.schedule(function()
              vim.cmd("edit!") -- reload file
              print("lint:fix complete")
            end)
          end,
        })
      end, {})
    end
  end,
})
