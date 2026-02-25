local M = {}

vim.keymap.set({ "n" }, "<leader>j", function() require("aerial").toggle() end, { silent = true })

-- vim.keymap.set({ "n" }, "zc", function()
--   if vim.fn.foldlevel(".") > 0 then vim.cmd("normal! zc") end
-- end, { silent = true })
--
-- vim.keymap.set({ "n" }, "zC", function()
--   if vim.fn.foldlevel(".") > 0 then vim.cmd("normal! zC") end
-- end, { silent = true })

vim.keymap.set({ "n", "x" }, "dp", ":diffput | diffu<cr>", { silent = true })
vim.keymap.set({ "n", "x" }, "do", ":diffget | diffu<cr>", { silent = true })
vim.keymap.set({ "n", "x" }, "doh", ":diffget //2 | diffu<cr>", { silent = true })
vim.keymap.set({ "n", "x" }, "dol", ":diffget //3 | diffu<cr>", { silent = true })

return M
