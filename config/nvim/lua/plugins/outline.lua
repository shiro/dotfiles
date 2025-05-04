local M = {
  {
    "stevearc/aerial.nvim",
    opts = {
      highlight_on_hover = true,
      autojump = true,
      close_on_select = true,
      disable_max_lines = 200000000,
      disable_max_size = 200000000, -- 200MB
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },
}

return M
