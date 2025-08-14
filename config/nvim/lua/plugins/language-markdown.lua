local M = {
  {
    "davidmh/mdx.nvim",
    config = true,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  -- embedded LSP
  {
    "jmbuhr/otter.nvim",
    branch = "global-config",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "markdown" },
    config = function()
      local otter = require("otter")
      otter.setup({
        extensions = {
          typescriptreact = "tsx",
          tsx = "tsx",
        },
      })
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*.md",
        callback = function() otter.activate() end,
      })
    end,
  },
}

return M
