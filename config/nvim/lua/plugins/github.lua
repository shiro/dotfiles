local M = {
  {
    "pwntester/octo.nvim",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      vim.treesitter.language.register("markdown", "octo")
      require("octo").setup({
        use_local_fs = true,
        mappings = {
          review_thread = {
            next_comment = { lhs = "]b", desc = "go to next comment" },
            prev_comment = { lhs = "[b", desc = "go to previous comment" },
          },
        },
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "octo",
        callback = function()
          vim.keymap.set("n", "[t", function()
            pcall(function() vim.cmd("normal! zc[fzO") end)
          end)

          vim.keymap.set("v", "<leader>qf", function()
            local start_line = vim.fn.line("'<") == 0 and vim.fn.line(".") or vim.fn.line("'<")
            local end_line = vim.fn.line("'>") == 0 and vim.fn.line(".") or vim.fn.line("'>")
            local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
            local qf_items = {}

            for i, line in ipairs(lines) do
              local actual_line_num = start_line + i - 1
              local fold_level = vim.fn.foldlevel(actual_line_num)
              local prev_fold_level = vim.fn.foldlevel(actual_line_num - 1)

              if fold_level ~= prev_fold_level and fold_level == 2 then
                local buffer_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                local content_lnr = actual_line_num
                local content_text = line:gsub("^%s*", "")

                -- Find first line that starts with any text from current line onwards
                for j = actual_line_num, #buffer_lines do
                  local check_line = buffer_lines[j]
                  if check_line and check_line:match("^%S") then
                    content_lnr = j
                    content_text = check_line:gsub("^%s*", "")
                    break
                  end
                end

                table.insert(qf_items, {
                  bufnr = vim.api.nvim_get_current_buf(),
                  lnum = content_lnr,
                  col = 1,
                  text = content_text,
                })
              end
            end

            vim.fn.setqflist(qf_items, "r")
            vim.cmd("copen")
          end, { desc = "Add fold start lines to quickfix", buffer = true })
        end,
      })
    end,
  },
}

return M
