local M = {
  {
    "kevinhwang91/rnvimr",
    -- keys = { { "<leader>l", "" } },
    init = function()
      vim.g.rnvimr_enable_ex = 1
      vim.g.rnvimr_enable_picker = 1
      vim.g.rnvimr_draw_border = 0
      vim.g.rnvimr_layout = {
        relative = "editor",
        width = vim.fn.winwidth(0),
        height = vim.fn.winheight(0) / 2,
        col = 0,
        row = vim.fn.winheight(0) / 4,
        style = "minimal",
      }
      -- vim.g.rnvimr_ranger_views = {
      -- 	-- { minwidth = 50, maxwidth = 89, ratio = { 1, 1 } },
      -- 	{ ratio = { 1, 1 } },
      -- }
      vim.g.rnvimr_ranger_cmd = {
        "ranger",
        "--cmd=set preview_directories false",
        "--cmd=set column_ratios 2,5,0",
        "--cmd=set preview_files false",
        "--cmd=set preview_images false",
        "--cmd=set padding_right false",
        "--cmd=set collapse_preview true",
      }
    end,
    config = function()
      vim.keymap.set("n", "<leader>l", function() vim.api.nvim_command("RnvimrToggle") end, {})
    end,
  },
}
return M
