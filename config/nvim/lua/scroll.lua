-- move cursor and scroll by a fixed distance, with center support
function Jump(distance, center)
  local view_info = vim.fn.winsaveview()
  if view_info == nil then return end

  local height = vim.fn.winheight(0)
  local cursor_row = view_info.lnum
  local buffer_lines = vim.fn.line("$")

  local target_row = cursor_row
  local remaining_distance = math.abs(distance)
  local direction = distance > 0 and 1 or -1

  -- move line by line, counting only non-folded lines
  while remaining_distance > 0 and target_row >= 1 and target_row <= buffer_lines do
    target_row = target_row + direction
    target_row = math.max(target_row, 1)
    target_row = math.min(target_row, buffer_lines)

    -- if we hit a fold, skip to the appropriate end
    if vim.fn.foldclosed(target_row) ~= -1 then
      if direction > 0 then
        target_row = vim.fn.foldclosedend(target_row)
      else
        target_row = vim.fn.foldclosed(target_row)
      end
      target_row = math.max(target_row, 1)
      target_row = math.min(target_row, buffer_lines)
    end

    remaining_distance = remaining_distance - 1
  end

  if center then
    -- scroll center cursor
    view_info.topline = target_row - math.floor(height / 2)
  else
    -- scroll by distance
    view_info.topline = math.max(view_info.topline + distance, 1)
  end
  -- avoid scrolling past last line
  view_info.topline = math.min(view_info.topline, math.max(buffer_lines - height - 6, 1))
  view_info.lnum = target_row

  vim.fn.winrestview(view_info)

  -- center the cursor after scrolling
  if center then vim.cmd("normal! zz") end
end

local M = {}

M.setup = function()
  vim.keymap.set("n", "<C-u>", function() Jump(math.max(vim.v.count, 1) * -18, true) end, {})
  vim.keymap.set("n", "<C-d>", function() Jump(math.max(vim.v.count, 1) * 18, true) end, {})
  vim.keymap.set("n", "<C-b>", function() Jump(math.max(vim.v.count, 1) * -32, true) end, {})
  vim.keymap.set("n", "<C-f>", function() Jump(math.max(vim.v.count, 1) * 32, true) end, {})

  vim.keymap.set("n", "<C-y>", function() Jump(math.max(vim.v.count, 1) * -3) end, {})
  vim.keymap.set("n", "<C-e>", function() Jump(math.max(vim.v.count, 1) * 3) end, {})
end

return M
