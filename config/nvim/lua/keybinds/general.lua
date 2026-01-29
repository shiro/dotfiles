local M = {}

vim.keymap.set({ "n" }, "<leader>j", function() require("aerial").toggle() end, { silent = true })

-- vim.keymap.set({ "n" }, "zc", function()
--   if vim.fn.foldlevel(".") > 0 then vim.cmd("normal! zc") end
-- end, { silent = true })
--
-- vim.keymap.set({ "n" }, "zC", function()
--   if vim.fn.foldlevel(".") > 0 then vim.cmd("normal! zC") end
-- end, { silent = true })

return M
