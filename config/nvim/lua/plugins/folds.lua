local M = {
  -- pretty folds {{{
  -- {
  --   "bbjornstad/pretty-fold.nvim",
  --   config = function()
  --     require("pretty-fold").setup({
  --       fill_char = " ",
  --       sections = {
  --         left = { "content" },
  --         right = {
  --           " ",
  --           "number_of_folded_lines",
  --           function(config) return config.fill_char:rep(3) end,
  --         },
  --       },
  --       process_comment_signs = false,
  --     })
  --   end,
  -- },
  {
    "kevinhwang91/nvim-ufo",
    dependencies = {
      "kevinhwang91/promise-async",
    },
    config = function()
      require("ufo").setup({
        provider_selector = function(bufnr, filetype, buftype) return { "treesitter", "indent" } end,
        preview = {
          win_config = {
            winblend = 0,
          },
        },
      })

      vim.keymap.set("n", "zR", require("ufo").openAllFolds)
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
      -- vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds)
      vim.keymap.set("n", "zm", require("ufo").closeFoldsWith)
      vim.keymap.set("n", "]f", function()
        require("ufo").goNextClosedFold()
        vim.cmd("normal! zz")
      end)
      vim.keymap.set("n", "[f", function()
        require("ufo").goPreviousClosedFold()
        vim.cmd("normal! zz")
      end)
      vim.keymap.set("n", "K", function()
        local winid = require("ufo").peekFoldedLinesUnderCursor()
        if winid then
          vim.api.nvim_set_current_win(winid)
          vim.keymap.set(
            "n",
            "<Esc>",
            function() vim.api.nvim_win_close(winid, true) end,
            { buffer = vim.api.nvim_win_get_buf(winid) }
          )
        end
      end)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "octo" },
        callback = function()
          require("ufo").detach()
          -- also reset the above keymaps
          vim.keymap.del("n", "zR")
          vim.keymap.del("n", "zM")
          vim.keymap.del("n", "zm")
          vim.keymap.del("n", "]f")
          vim.keymap.del("n", "[f")
          vim.keymap.del("n", "K")
          -- vim.opt_local.foldenable = false
        end,
        once = true,
      })
    end,
  },
}
return M
