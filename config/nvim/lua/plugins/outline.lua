local M = {
  {
    "stevearc/aerial.nvim",
    opts = {
      highlight_on_hover = true,
      autojump = true,
      close_on_select = true,
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },
}

return M
