local M = {}

local LINKS_TO_TEXT = " links to "
local LINKS_TO_LEN = #LINKS_TO_TEXT
local UNUSED_TEXT = " (unused)"

local state = {
  splits = {},
  autocmd_ids = {},
}

--- Process extmarks and add highlight groups to the list
--- @param extmarks table|nil List of extmarks from vim.inspect_pos
--- @param highlights table List to store highlight group information
--- @param seen table Set of already processed highlight groups
local function process_extmarks(extmarks, highlights, seen)
  if not extmarks then return end

  for _, extmark in ipairs(extmarks) do
    local hl_group = extmark.opts and extmark.opts.hl_group
    if not hl_group or seen[hl_group] or hl_group:match("^Illuminate") then goto continue end

    seen[hl_group] = true
    table.insert(highlights, {
      name = hl_group,
      target = extmark.opts.hl_group_link or hl_group,
      priority = extmark.opts.priority,
      index = #highlights + 1,
    })

    ::continue::
  end
end

--- Process treesitter highlights and add to the list
--- @param treesitter table|nil List of treesitter highlights from vim.inspect_pos
--- @param highlights table List to store highlight group information
--- @param seen table Set of already processed highlight groups
local function process_treesitter(treesitter, highlights, seen)
  if not treesitter then return end

  for _, ts in ipairs(treesitter) do
    local hl_group = ts.hl_group
    if not hl_group or seen[hl_group] then goto continue end

    seen[hl_group] = true
    table.insert(highlights, {
      name = hl_group,
      target = ts.hl_group_link or hl_group,
      priority = 100,
      index = #highlights + 1,
    })

    ::continue::
  end
end

--- Process semantic tokens and add highlight groups to the list
--- @param semantic_tokens table|nil List of semantic tokens from vim.inspect_pos
--- @param highlights table List to store highlight group information
--- @param seen table Set of already processed highlight groups
local function process_semantic_tokens(semantic_tokens, highlights, seen)
  if not semantic_tokens then return end

  for _, token in ipairs(semantic_tokens) do
    local hl_group = token.opts and token.opts.hl_group
    if not hl_group or seen[hl_group] then goto continue end

    seen[hl_group] = true
    table.insert(highlights, {
      name = hl_group,
      target = token.opts.hl_group_link or hl_group,
      priority = token.opts.priority or 125,
      index = #highlights + 1,
    })

    ::continue::
  end
end

--- Check if a highlight group has color properties
--- @param hl_group string|nil The highlight group name to check
--- @return boolean Whether the highlight group has color properties
local function has_colors(hl_group)
  if not hl_group then return false end

  local hl_def = vim.api.nvim_get_hl(0, { name = hl_group })
  if not hl_def then return false end

  return hl_def.fg ~= nil
    or hl_def.bg ~= nil
    or hl_def.sp ~= nil
    or hl_def.ctermfg ~= nil
    or hl_def.ctermbg ~= nil
    or hl_def.bold == true
    or hl_def.italic == true
    or hl_def.underline == true
    or hl_def.undercurl == true
    or hl_def.underdouble == true
    or hl_def.underdotted == true
    or hl_def.underdashed == true
    or hl_def.strikethrough == true
    or hl_def.reverse == true
    or hl_def.standout == true
end

--- Get all highlight groups at the current cursor position
--- @return table List of highlight group information
local function get_highlights()
  if not vim.inspect_pos then return {} end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local buf = vim.api.nvim_get_current_buf()
  local inspect_data = vim.inspect_pos(buf, row - 1, col)

  local highlights = {}
  local seen = {}

  process_extmarks(inspect_data.extmarks, highlights, seen)
  process_treesitter(inspect_data.treesitter, highlights, seen)
  process_semantic_tokens(inspect_data.semantic_tokens, highlights, seen)

  table.sort(highlights, function(a, b)
    local a_priority = a.priority or 0
    local b_priority = b.priority or 0
    if a_priority ~= b_priority then return a_priority > b_priority end
    return a.index > b.index
  end)

  return highlights
end

--- Format highlight groups into display lines with metadata
--- @param highlights table List of highlight group information
--- @return table List of formatted display items
local function format_highlights(highlights)
  if #highlights == 0 then return { "No highlight groups found" } end

  local lines = {}
  for _, hl in ipairs(highlights) do
    local is_linked = hl.name ~= hl.target
    local text
    local unused_pos = nil

    if is_linked then
      text = hl.name .. LINKS_TO_TEXT .. hl.target
      if not has_colors(hl.target) then
        unused_pos = string.len(text)
        text = text .. UNUSED_TEXT
      end
    else
      text = hl.name
    end

    table.insert(lines, {
      text = text,
      hl_group = hl.target,
      links_pos = is_linked and string.len(hl.name) or nil,
      unused_pos = unused_pos,
    })
  end
  return lines
end

--- Calculate popup dimensions and position
--- @param content table List of content items to display in popup
--- @return table Popup window configuration
local function get_popup_config(content)
  local cursor_screen_row = vim.fn.screenrow()
  local cursor_screen_col = vim.fn.screencol()
  local screen_width = vim.o.columns
  local screen_height = vim.o.lines - vim.o.cmdheight - 1

  -- Calculate required width
  local max_width = 0
  for _, item in ipairs(content) do
    local text = type(item) == "string" and item or item.text
    max_width = math.max(max_width, vim.fn.strdisplaywidth(text))
  end

  local title_width = vim.fn.strdisplaywidth(" Color Inspector ")
  local width = math.max(max_width + 2, title_width + 2, 20)
  width = math.min(width, screen_width - 4)

  local height = math.min(#content, screen_height - 4)

  -- Position popup near cursor
  local row = cursor_screen_row + 1
  local col = cursor_screen_col + 2

  -- Adjust if popup would go off screen
  if col + width > screen_width then col = cursor_screen_col - width - 1 end
  if row + height > screen_height then row = cursor_screen_row - height - 1 end

  -- Ensure popup stays on screen
  row = math.max(0, math.min(row, screen_height - height))
  col = math.max(0, math.min(col, screen_width - width))

  return {
    relative = "editor",
    row = row - 1,
    col = col - 1,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = " Color Inspector ",
    title_pos = "center",
  }
end

--- Create or get buffer for popup for a specific split
--- @param split_winid number The window ID for the split
--- @return number|nil Buffer number or nil if split state not found
local function get_or_create_buffer(split_winid)
  local split_state = state.splits[split_winid]
  if not split_state then return nil end

  if not split_state.bufnr or not vim.api.nvim_buf_is_valid(split_state.bufnr) then
    split_state.bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[split_state.bufnr].bufhidden = "wipe"
    vim.bo[split_state.bufnr].buftype = "nofile"
    vim.bo[split_state.bufnr].swapfile = false

    -- Set up buffer keybindings for when focused
    local function close_popup()
      if split_state.popup_winid and vim.api.nvim_win_is_valid(split_state.popup_winid) then
        vim.api.nvim_win_close(split_state.popup_winid, true)
        split_state.popup_winid = nil
      end
      split_state.should_show = false
    end

    -- Set buffer-local keymaps
    vim.keymap.set("n", "<Esc>", close_popup, { buffer = split_state.bufnr, silent = true })
    vim.keymap.set("n", "<C-c>", close_popup, { buffer = split_state.bufnr, silent = true })

    -- Add autocmd to clean up state when window is closed externally
    vim.api.nvim_create_autocmd("WinClosed", {
      buffer = split_state.bufnr,
      callback = function() split_state.popup_winid = nil end,
    })
  end
  return split_state.bufnr
end

--- Set buffer content
--- @param bufnr number Buffer number to set content for
--- @param content table List of content items to display
local function set_buffer_content(bufnr, content)
  local lines = {}
  for _, item in ipairs(content) do
    table.insert(lines, type(item) == "string" and item or item.text)
  end
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

--- Create a highlight group for unused targets (same color as Comment with strikethrough)
--- @return string The name of the created highlight group
local function create_unused_highlight()
  local unused_hl_name = "ColorInspectorUnused"
  -- Get the Comment highlight group's color
  local comment_hl = vim.api.nvim_get_hl(0, { name = "Comment" })
  vim.api.nvim_set_hl(0, unused_hl_name, {
    fg = comment_hl.fg,
    ctermfg = comment_hl.ctermfg,
    strikethrough = true,
  })
  return unused_hl_name
end

--- Apply highlights to buffer
--- @param bufnr number Buffer number to apply highlights to
--- @param content table List of content items with highlight information
--- @param ns_id number Namespace ID for highlights
local function apply_highlights(bufnr, content, ns_id)
  local unused_hl = create_unused_highlight()

  -- Helper function to add highlight extmark
  local function add_highlight(line_idx, start_col, end_col, hl_group)
    pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_id, line_idx, start_col, {
      end_col = end_col,
      hl_group = hl_group,
    })
  end

  for i, item in ipairs(content) do
    if type(item) == "string" or not item.hl_group then goto continue end

    local line_idx = i - 1
    local line_len = #vim.api.nvim_buf_get_lines(bufnr, line_idx, line_idx + 1, false)[1]

    if item.links_pos then
      if item.unused_pos then
        -- If target is unused, highlight everything with appropriate colors
        add_highlight(line_idx, 0, item.links_pos, unused_hl)
        add_highlight(line_idx, item.links_pos, item.links_pos + LINKS_TO_LEN, "Comment")
        add_highlight(line_idx, item.links_pos + LINKS_TO_LEN, item.unused_pos, unused_hl)
        add_highlight(line_idx, item.unused_pos, line_len, "Comment")
      else
        -- Normal linked highlight group
        add_highlight(line_idx, 0, item.links_pos, item.hl_group)
        add_highlight(line_idx, item.links_pos, item.links_pos + LINKS_TO_LEN, "Comment")
        add_highlight(line_idx, item.links_pos + LINKS_TO_LEN, line_len, item.hl_group)
      end
    else
      -- Simple highlight group (not linked)
      add_highlight(line_idx, 0, line_len, item.hl_group)
    end

    ::continue::
  end
end

--- Update popup for a specific split
--- @param split_winid number The window ID for the split
local function update_popup(split_winid)
  local split_state = state.splits[split_winid]
  if not split_state or not split_state.should_show then return end

  -- Don't update if popup is currently focused
  local current_win = vim.api.nvim_get_current_win()
  if split_state.popup_winid and current_win == split_state.popup_winid then return end

  local highlights = get_highlights()
  local content = format_highlights(highlights)

  -- Close existing popup window
  if split_state.popup_winid and vim.api.nvim_win_is_valid(split_state.popup_winid) then
    vim.api.nvim_win_close(split_state.popup_winid, true)
  end

  -- Prepare buffer
  local bufnr = get_or_create_buffer(split_winid)
  if not bufnr then return end

  set_buffer_content(bufnr, content)

  -- Create or reuse namespace for this split
  if not split_state.ns_id then split_state.ns_id = vim.api.nvim_create_namespace("color_inspector_" .. split_winid) end

  apply_highlights(bufnr, content, split_state.ns_id)

  -- Create new popup window
  local config = get_popup_config(content)
  split_state.popup_winid = vim.api.nvim_open_win(bufnr, false, config)
  vim.wo[split_state.popup_winid].winhl = "Normal:NormalFloat,Border:FloatBorder"
  vim.wo[split_state.popup_winid].wrap = false
end

--- Hide popup for a specific split
--- @param split_winid number The window ID for the split
local function hide_popup(split_winid)
  local split_state = state.splits[split_winid]
  if not split_state then return end

  if split_state.popup_winid and vim.api.nvim_win_is_valid(split_state.popup_winid) then
    vim.api.nvim_win_close(split_state.popup_winid, true)
    split_state.popup_winid = nil
  end
  split_state.should_show = false
end

--- Show popup for a specific split
--- @param split_winid number The window ID for the split
--- @param delay boolean|nil Whether to delay showing the popup
local function show_popup(split_winid, delay)
  local split_state = state.splits[split_winid]
  if not split_state then return end

  split_state.should_show = true

  if delay then
    -- Small delay to ensure cursor position is stable
    vim.defer_fn(function()
      if split_state.should_show then update_popup(split_winid) end
    end, 50)
  else
    update_popup(split_winid)
  end
end

--- Clean up all splits and autocmds
local function cleanup()
  -- Close all split popups
  for _, split_state in pairs(state.splits) do
    if split_state.popup_winid and vim.api.nvim_win_is_valid(split_state.popup_winid) then
      vim.api.nvim_win_close(split_state.popup_winid, true)
    end
  end

  -- Clear splits table
  state.splits = {}

  -- Clean up global autocmds
  for _, autocmd_id in ipairs(state.autocmd_ids) do
    if autocmd_id then vim.api.nvim_del_autocmd(autocmd_id) end
  end
  state.autocmd_ids = {}
end

--- Enable inspector for current split
local function enable_split()
  local current_winid = vim.api.nvim_get_current_win()

  -- Initialize split state if not exists
  if not state.splits[current_winid] then
    state.splits[current_winid] = {
      winid = current_winid,
      bufnr = nil,
      popup_winid = nil,
      should_show = true,
      ns_id = nil,
    }
  else
    -- Re-enable existing split
    state.splits[current_winid].should_show = true
  end

  -- Set up global autocmds if this is the first split
  if vim.tbl_count(state.splits) == 1 then
    -- Cursor movement autocmds
    local cursor_autocmd = vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      callback = function()
        local current_win = vim.api.nvim_get_current_win()

        -- Check if current window is tracked and has an active popup
        local split_state = state.splits[current_win]
        if not split_state then return end

        -- Don't update if popup is currently focused
        if split_state.popup_winid and current_win == split_state.popup_winid then return end

        vim.schedule(function() update_popup(current_win) end)
      end,
    })
    table.insert(state.autocmd_ids, cursor_autocmd)

    -- Window enter autocmds
    local win_enter_autocmd = vim.api.nvim_create_autocmd("WinEnter", {
      callback = function()
        local current_win = vim.api.nvim_get_current_win()
        local split_state = state.splits[current_win]

        if split_state then
          -- Show popup for tracked splits with delay to ensure stable cursor position
          show_popup(current_win, true)
        else
          -- Hide popups from other splits when entering untracked windows
          for tracked_winid, tracked_state in pairs(state.splits) do
            if tracked_state.popup_winid and vim.api.nvim_win_is_valid(tracked_state.popup_winid) then
              -- Check if we're entering the popup window itself
              if current_win ~= tracked_state.popup_winid then hide_popup(tracked_winid) end
            end
          end
        end
      end,
    })
    table.insert(state.autocmd_ids, win_enter_autocmd)

    -- Window leave autocmds
    local win_leave_autocmd = vim.api.nvim_create_autocmd("WinLeave", {
      callback = function()
        local current_win = vim.api.nvim_get_current_win()
        local split_state = state.splits[current_win]

        if split_state then
          -- Schedule hiding popup when leaving tracked splits
          vim.schedule(function()
            local new_win = vim.api.nvim_get_current_win()
            -- Only hide if we didn't switch to the popup window
            if split_state.popup_winid and new_win ~= split_state.popup_winid then hide_popup(current_win) end
          end)
        end
      end,
    })
    table.insert(state.autocmd_ids, win_leave_autocmd)

    -- Window closure autocmds
    local win_closed_autocmd = vim.api.nvim_create_autocmd("WinClosed", {
      callback = function(event)
        local closed_winid = tonumber(event.match)
        if not closed_winid then return end

        -- Clean up state for closed splits
        if state.splits[closed_winid] then
          state.splits[closed_winid] = nil

          -- If no splits remain, clean up everything
          if vim.tbl_count(state.splits) == 0 then cleanup() end
        end

        -- Also check if a popup window was closed
        for _, split_state in pairs(state.splits) do
          if split_state.popup_winid == closed_winid then split_state.popup_winid = nil end
        end
      end,
    })
    table.insert(state.autocmd_ids, win_closed_autocmd)
  end

  -- Show popup for this split
  show_popup(current_winid)
end

--- Disable inspector for current split
local function disable_split()
  local current_winid = vim.api.nvim_get_current_win()
  local split_state = state.splits[current_winid]

  if split_state then
    -- Hide popup and remove from splits
    hide_popup(current_winid)
    state.splits[current_winid] = nil

    -- If no splits remain, clean up everything
    if vim.tbl_count(state.splits) == 0 then cleanup() end
  end
end

--- Toggle color inspector for current split
function M.toggle()
  local current_winid = vim.api.nvim_get_current_win()
  local split_state = state.splits[current_winid]

  if split_state then
    -- Split is already enabled, disable it
    disable_split()
  else
    -- Split is not enabled, enable it
    enable_split()
  end
end

--- Focus the popup window if it exists and is valid for current split
--- @return boolean Whether the popup window was successfully focused
function M.focus()
  local current_winid = vim.api.nvim_get_current_win()
  local split_state = state.splits[current_winid]

  if not split_state then return false end

  -- If popup doesn't exist but should be shown, create it first
  if not split_state.popup_winid or not vim.api.nvim_win_is_valid(split_state.popup_winid) then
    if split_state.should_show then
      update_popup(current_winid)
    else
      show_popup(current_winid)
    end
  end

  if split_state.popup_winid and vim.api.nvim_win_is_valid(split_state.popup_winid) then
    vim.api.nvim_set_current_win(split_state.popup_winid)
    return true
  end
  return false
end

--- Check if inspector is enabled for current split
--- @return boolean Whether the inspector is enabled for current split
function M.is_enabled()
  local current_winid = vim.api.nvim_get_current_win()
  return state.splits[current_winid] ~= nil
end

--- Get enabled splits count
--- @return number Number of currently enabled splits
function M.get_enabled_splits_count() return vim.tbl_count(state.splits) end

return M
