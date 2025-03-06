local M = {}

vim.keymap.set({ "n" }, "<leader>j", function() require("aerial").toggle() end, { silent = true })

return M
