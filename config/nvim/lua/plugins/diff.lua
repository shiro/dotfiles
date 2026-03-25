local function close_tab() vim.cmd("tabclose") end

local M = {
  {
    "sindrets/diffview.nvim",
    config = function()
      local actions = require("diffview.actions")

      require("diffview").setup({
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
        hooks = {
          view_opened = function()
            vim.defer_fn(function() actions.focus_entry() end, 100)

            -- preview files on hover in file view
            local bufnr = vim.api.nvim_get_current_buf()
            vim.api.nvim_create_autocmd("CursorMoved", {
              buffer = bufnr,
              callback = function()
                if vim.fn.getline("."):match("") then return end

                actions.select_entry()
              end,
            })
          end,
        },
        keymaps = {
          view = {
            ["<C-c>"] = close_tab,
            ["]q"] = actions.select_next_entry,
            ["[q"] = actions.select_prev_entry,
          },
          file_panel = {
            ["<C-c>"] = close_tab,
            -- also focus entry on select
            ["<cr>"] = function()
              actions.select_entry()
              actions.focus_entry()
            end,
          },
        },
      })
    end,
  },
}

return M
