local M = {
  {
    "pwntester/octo.nvim",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("octo").setup({
        use_local_fs = true,
        mappings = {
          review_thread = {
            next_comment = { lhs = "]b", desc = "go to next comment" },
            prev_comment = { lhs = "[b", desc = "go to previous comment" },
          },
        },
      })
    end,
  },
}

return M
