local M = {
  -- pretty UI {{{
  {
    "stevearc/dressing.nvim",
    opts = {},
    event = "VeryLazy",
  },
  -- show color hex codes
  {
    "NvChad/nvim-colorizer.lua",
    event = "VeryLazy",
    config = function() require("colorizer").setup({ user_default_options = { mode = "virtualtext", names = false } }) end,
  },
}
return M
