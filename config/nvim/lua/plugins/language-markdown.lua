local M = {
  {
    "davidmh/mdx.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  -- embedded LSP
  {
    "jmbuhr/otter.nvim",
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
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      image = {
        doc = {
          inline = false,
          max_width = 20,
          max_height = 20,
        },
      },
    },
  },
}

return M
