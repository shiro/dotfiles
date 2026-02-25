local function close_tab() vim.cmd("tabclose") end

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
      keymaps = {
        view = { ["<C-c>"] = close_tab },
        file_panel = { ["<C-c>"] = close_tab },
      },
    },
  },
}

return M
