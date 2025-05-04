local M = { -- find and replace
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
return M
