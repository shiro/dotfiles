local function close_tab() vim.cmd("tabclose") end

local M = {
  {
    "sindrets/diffview.nvim",
    config = function()
      local actions = require("diffview.actions")



      require("diffview").setup({
        file_panel = {
          listing_style = "tree",
          win_config = {
            position = "bottom",
            height = 30,
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
                -- avoid opening preview for folders
                if vim.fn.getline("."):match("") then return end

                actions.select_entry()
              end,
            })

          end,
          diff_buf_read = function(bufnr)
            -- Fix filetype detection for diff buffers
            -- diffview creates buffers programmatically without triggering BufRead autocmds
            local bufname = vim.api.nvim_buf_get_name(bufnr)
            if bufname and bufname ~= "" then
              local ft = vim.filetype.match({ filename = bufname, buf = bufnr })
              if ft then
                vim.bo[bufnr].filetype = ft
              end
            end
          end,
        },
        keymaps = {
          view = {
            ["<C-c>"] = close_tab,
            ["]q"] = actions.select_next_entry,
            ["[q"] = actions.select_prev_entry,
            ["t"] = actions.toggle_files,
          },
          file_panel = {
            ["<C-c>"] = close_tab,
            ["t"] = actions.toggle_files,
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
