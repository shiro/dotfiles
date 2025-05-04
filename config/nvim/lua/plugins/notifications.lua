local M = {
  -- fancy notifications
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      require("notify").setup({
        render = "minimal",
        stages = "static",
        top_down = false,
      })
    end,
  },
}
return M
