local M = {
  {
    "sindrets/diffview.nvim",
    opts = {
      file_panel = {
        listing_style = "list",
        win_config = {
          position = "bottom",
          height = 10,
          -- win_opts = {},
        },
      },
      view = {
        default = {
          -- layout = "diff2_vertical",
        },
      },
    },
  },
}

return M
