-- Gets lines on which threads start
---@return integer[]
local function get_thread_lines()
  local constants = require("octo.constants")

  local lines = {} ---@type integer[]
  local marks = vim.api.nvim_buf_get_extmarks(0, constants.OCTO_THREAD_NS, 0, -1, { details = true })

  for _, mark in ipairs(marks) do
    table.insert(lines, mark[2])
  end
  table.sort(lines)

  return lines
end

---@param current_line integer
---@param lines integer[]
---@param cursor integer[]
local function prev_line(current_line, lines, cursor)
  if not lines or not current_line then return end
  if #lines == 0 then return end

  ---@type integer?
  local target
  if current_line > lines[#lines] + 2 then
    -- go to last comment
    target = lines[#lines] + 1
  elseif current_line <= lines[1] + 2 then
    -- do not move
    target = current_line - 1
  else
    for i = 1, #lines, 1 do
      if current_line <= lines[i] + 2 then
        target = lines[i - 1] + 1
        break
      end
    end
  end

  vim.api.nvim_win_set_cursor(0, { target + 1, cursor[2] })
end

---@param current_line integer
---@param lines integer[]
---@param cursor integer[]
local function next_line(current_line, lines, cursor)
  if not lines or not current_line then return end
  if #lines == 0 then return end

  ---@type integer?
  local target
  if current_line < lines[1] + 1 then
    -- go to first comment
    target = lines[1] + 1
  elseif current_line > lines[#lines] + 1 then
    -- do not move
    target = current_line - 1
  else
    for i = #lines, 1, -1 do
      if current_line >= lines[i] + 1 then
        target = lines[i + 1] + 1
        break
      end
    end
  end

  vim.api.nvim_win_set_cursor(0, { target + 1, cursor[2] })
end

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

      require("telescope").load_extension("octo")

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "octo",
        callback = function()
          -- don't wrap text
          vim.opt_local.textwidth = 0

          local utils = require("octo.utils")
          local buffer = utils.get_current_buffer()

          -- thread navigation in PR view
          if buffer and buffer:isPullRequest() then
            vim.keymap.set("n", "[t", function()
              local lines = get_thread_lines()
              if not lines then return end

              local cursor = vim.api.nvim_win_get_cursor(0)
              local current_line = cursor[1]

              prev_line(current_line, lines, cursor)
            end)

            vim.keymap.set("n", "]t", function()
              local lines = get_thread_lines()
              if not lines then return end

              local cursor = vim.api.nvim_win_get_cursor(0)
              local current_line = cursor[1]

              next_line(current_line, lines, cursor)
            end)
          end

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
