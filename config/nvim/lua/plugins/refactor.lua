local M = {
  -- find and replace
  {
    "nvim-pack/nvim-spectre",
    lazy = true,
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<C-S-R>", "<cmd>lua require('spectre').toggle()<CR>", mode = "n", silent = true },
      { "<Leader>R", "<cmd>lua require('spectre').toggle()<CR>", mode = "n", silent = true },
    },
  },
}

-- rename symbol
vim.keymap.set("n", "<leader>e", vim.lsp.buf.rename, {})
-- refactor actions
vim.keymap.set(
  { "n", "x" },
  "<leader>r",
  function() require("telescope").extensions.refactoring.refactors() end,
  { silent = true }
)
-- rename file
vim.api.nvim_create_user_command("RenameFile", "silent CocCommand workspace.renameCurrentFile", {})

return M
