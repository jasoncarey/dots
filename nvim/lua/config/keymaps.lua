-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Exit insert mode with jk
vim.keymap.set("i", "jk", "<Esc>", {
  desc = "Exit insert mode",
  silent = true,
})

-- Keep cursor centered when paging
-- vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })
-- vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })

vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode", silent = true })
vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode", silent = true })

-- Toggle inlay hints
vim.keymap.set("n", "<leader>uh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

vim.keymap.set("n", "<leader>lf", "<cmd>Fix<cr>", { desc = "lint fix" })
