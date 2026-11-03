local M = {}

local telescopeUtilities = require("telescope.utils")
local telescopeMakeEntryModule = require("telescope.make_entry")
local plenaryStrings = require("plenary.strings")
local devIcons = require("nvim-web-devicons")
local telescopeEntryDisplayModule = require("telescope.pickers.entry_display")

local fileTypeIconWidth = plenaryStrings.strdisplaywidth(devIcons.get_icon("fname", { default = true }))

---- Helper functions ----

-- Gets the File Path and its Tail (the file name) as a Tuple
function M.getPathAndTail(fileName)
  -- Get the Tail
  local bufferNameTail = telescopeUtilities.path_tail(fileName)

  -- Now remove the tail from the Full Path
  local pathWithoutTail = require("plenary.strings").truncate(fileName, #fileName - #bufferNameTail, "")

  -- Apply truncation and other pertaining modifications to the path according to Telescope path rules
  local pathToDisplay = telescopeUtilities.transform_path({
    path_display = { "truncate" },
  }, pathWithoutTail)

  return bufferNameTail, pathToDisplay
end

function M.printErrInvalidArgument(opts)
  print("Incorrect argument format. Correct format is: { picker = 'desiredPicker', (optional) options = { ... } }")
end

function GetGitStatus()
  local output = vim.fn.system({ "git", "status", "-s" })
  local lines = vim.split(output, "\n")
  local status_map = {}
  for _, line in ipairs(lines) do
    local status = line:sub(1, 2)
    local filename = line:sub(4)
    if filename ~= "" then status_map[filename] = status end
  end
  return status_map
end

function M.prettyFilesPicker(pickerAndOptions)
  if type(pickerAndOptions) ~= "table" or pickerAndOptions.picker == nil then
    M.printErrInvalidArgument()
    return
  end

  local options = pickerAndOptions.options or {}

  local originalEntryMaker = telescopeMakeEntryModule.gen_from_file(options)

  local status_map = GetGitStatus()

  options.entry_maker = function(line)
    local originalEntryTable = originalEntryMaker(line)

    local displayer = telescopeEntryDisplayModule.create({
      separator = " ",
      items = {
        { width = fileTypeIconWidth },
        { width = nil },
        { width = nil },
        { width = nil },
        { width = 2 },
        -- { remaining = true },
      },
    })

    originalEntryTable.display = function(entry)
      -- Get the Tail and the Path to display
      local tail, pathToDisplay = M.getPathAndTail(entry.value)

      -- Get the Icon with its corresponding Highlight information
      local icon, iconHighlight = telescopeUtilities.get_devicons(tail)

      -- if the filename is non-descriptive, use directory name instead
      if tail == "index.ts" or tail == "index.tsx" or tail == "mod.rs" then
        local foo = telescopeUtilities.path_tail(pathToDisplay)
        tail = foo .. " (" .. tail .. ")"
      end

      -- Add an extra space to the tail so that it looks nicely separated from the path
      local tailForDisplay = tail .. " "

      local status = ""
      local highlight = ""
      if status_map[entry.value] ~= nil then
        status = status_map[entry.value]
        if status == "??" then
          status = "⠀A"
          highlight = "diffAdded"
        elseif status:sub(1, 1) == "A" then
          highlight = "diffAdded"
        elseif status:sub(2, 2) == "M" then
          highlight = "diffChanged"
        elseif status:sub(1, 1) == "M" then
          highlight = "diffChanged"
        elseif status:sub(2, 2) == "D" then
          highlight = "diffRemoved"
        end
      end

      local padding = string.rep(
        " ",
        vim.fn.winwidth(0) - fileTypeIconWidth - string.len(tailForDisplay) - string.len(pathToDisplay) - 9
      )

      return displayer({
        { icon, iconHighlight },
        tailForDisplay,
        { pathToDisplay, "TelescopeResultsComment" },
        padding,
        { status, highlight },
      })
    end

    return originalEntryTable
  end

  if pickerAndOptions.picker == "find_files" then
    require("telescope.builtin").find_files(options)
  elseif pickerAndOptions.picker == "git_files" then
    require("telescope.builtin").git_files(options)
  elseif pickerAndOptions.picker == "oldfiles" then
    require("telescope.builtin").oldfiles(options)
  elseif pickerAndOptions.picker == "" then
    print("Picker was not specified")
  else
    print("Picker is not supported by Pretty Find Files")
  end
end

function M.prettyGitPicker(opts)
  if type(opts) ~= "table" then
    M.printErrInvalidArgument()
    return
  end
  options = opts or {}

  local originalEntryMaker = telescopeMakeEntryModule.gen_from_git_status(options)

  options.entry_maker = function(line)
    local originalEntryTable = originalEntryMaker(line) or {}

    local displayer = telescopeEntryDisplayModule.create({
      separator = " ",
      items = {
        { width = fileTypeIconWidth },
        { width = 2 },
        { width = nil },
        { remaining = true },
      },
    })

    local filepath = line:sub(4)
    originalEntryTable.path = filepath
    originalEntryTable.ordinal = filepath

    originalEntryTable.display = function(entry)
      if entry.status == nil then entry.status = "" end
      local status = entry.status
      if status:sub(2, 2) == " " then status = status:sub(1, 1) .. "⠀" end

      local tail, pathToDisplay = M.getPathAndTail(filepath)

      -- if directory, get the basename and append '/'
      if tail == "" then
        tail, _ = M.getPathAndTail(filepath:sub(1, -2))
        tail = tail .. "/"
      end

      local highlight = ""
      if entry.status == "??" then
        status = "⠀A"
        highlight = "diffAdded"
      elseif entry.status:sub(1, 1) == "A" then
        highlight = "diffAdded"
      elseif entry.status:sub(2, 2) == "M" then
        highlight = "diffChanged"
      elseif entry.status:sub(1, 1) == "M" then
        highlight = "diffChanged"
      elseif entry.status:sub(2, 2) == "D" then
        highlight = "diffRemoved"
      end

      local tailForDisplay = tail .. " "

      local icon, iconHighlight = telescopeUtilities.get_devicons(tail)

      return displayer({
        { icon, iconHighlight },
        { status, highlight },
        tailForDisplay,
        { pathToDisplay, "TelescopeResultsComment" },
      })
    end

    return originalEntryTable
  end

  require("telescope.builtin").git_files(options)
end

-- opts.branch: list files changed against this branch (git diff)
-- no branch: list working tree changes against HEAD (git status)
function M.prettyChangedFilesPicker(opts)
  if type(opts) ~= "table" then
    M.printErrInvalidArgument()
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local ref = opts.branch or "HEAD"
  local results = {}

  local output = vim.fn.systemlist({ "git", "diff", "--name-status", ref })
  if vim.v.shell_error ~= 0 then
    vim.notify("git diff failed:\n" .. table.concat(output, "\n"), vim.log.levels.ERROR)
    return
  end

  for _, line in ipairs(output) do
    if line ~= "" then
      local fields = vim.split(line, "\t", { plain = true })
      -- renames and copies list the old path first and the new path last
      table.insert(results, { status = fields[1]:sub(1, 1), path = fields[#fields] })
    end
  end

  -- untracked files aren't in git diff, so add them as added when listing working tree changes
  if not opts.branch then
    for _, path in ipairs(vim.fn.systemlist({ "git", "ls-files", "--others", "--exclude-standard" })) do
      if path ~= "" then table.insert(results, { status = "A", path = path }) end
    end
  end

  local displayer = telescopeEntryDisplayModule.create({
    separator = " ",
    items = {
      { width = fileTypeIconWidth },
      { width = nil },
      { width = nil },
      { width = nil },
      { width = 2 },
    },
  })

  local entry_maker = function(item)
    local highlight = "diffChanged"
    if item.status == "A" then
      highlight = "diffAdded"
    elseif item.status == "D" then
      highlight = "diffRemoved"
    end

    return {
      value = item.path,
      ordinal = item.path,
      path = item.path,
      status = item.status,
      display = function()
        local tail, pathToDisplay = M.getPathAndTail(item.path)
        local icon, iconHighlight = telescopeUtilities.get_devicons(tail)

        local tailForDisplay = tail .. " "
        local padding = string.rep(
          " ",
          vim.fn.winwidth(0) - fileTypeIconWidth - string.len(tailForDisplay) - string.len(pathToDisplay) - 9
        )

        return displayer({
          { icon, iconHighlight },
          tailForDisplay,
          { pathToDisplay, "TelescopeResultsComment" },
          padding,
          { item.status .. "⠀", highlight },
        })
      end,
    }
  end

  pickers
    .new({}, {
      prompt_title = opts.branch and ("Diff files against " .. opts.branch) or "Diff files",
      finder = finders.new_table({
        results = results,
        entry_maker = entry_maker,
      }),
      sorter = conf.file_sorter({}),
      previewer = false,
      layout_strategy = opts.layout_strategy,
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if not entry then return end

          -- deleted files don't exist in the working tree, so read them from the ref
          if entry.status == "D" then
            vim.cmd("Gedit " .. ref .. ":" .. entry.path)
          else
            vim.cmd("edit " .. vim.fn.fnameescape(entry.path))
          end
        end)
        return true
      end,
    })
    :find()
end

function M.prettyGrepPicker(opts)
  if type(opts) ~= "table" or opts.picker == nil then
    M.printErrInvalidArgument()
    return
  end

  options = opts.options or {}

  local originalEntryMaker = telescopeMakeEntryModule.gen_from_vimgrep(options)

  options.entry_maker = function(line)
    local originalEntryTable = originalEntryMaker(line)

    local displayer = telescopeEntryDisplayModule.create({
      separator = " ", -- Telescope will use this separator between each entry item
      items = {
        { width = fileTypeIconWidth },
        { width = nil },
        { width = nil }, -- Maximum path size, keep it short
        { remaining = true },
      },
    })

    originalEntryTable.display = function(entry)
      local tail, pathToDisplay = M.getPathAndTail(entry.filename)
      local icon, iconHighlight = telescopeUtilities.get_devicons(tail)

      local coordinates = ""

      if not options.disable_coordinates then
        if entry.lnum then
          if entry.col then
            coordinates = string.format(" -> %s:%s", entry.lnum, entry.col)
          else
            coordinates = string.format(" -> %s", entry.lnum)
          end
        end
      end

      -- Append coordinates to tail
      tail = tail .. coordinates

      -- Add an extra space to the tail so that it looks nicely separated from the path
      local tailForDisplay = tail .. " "

      -- Encode text if necessary
      local text = options.file_encoding and vim.iconv(entry.text, options.file_encoding, "utf8") or entry.text

      return displayer({
        { icon, iconHighlight },
        tailForDisplay,
        { pathToDisplay, "TelescopeResultsComment" },
        text,
      })
    end

    return originalEntryTable
  end

  if opts.picker == "live_grep" then
    require("telescope.builtin").live_grep(options)
  elseif opts.picker == "grep_string" then
    require("telescope.builtin").grep_string(options)
  elseif opts.picker == "" then
    print("Picker was not specified")
  else
    print("Picker is not supported by Pretty Grep Picker")
  end
end

function M.prettyWorkspaceSymbolsPicker(opts)
  if opts ~= nil and type(opts) ~= "table" then
    M.printErrInvalidArgument()
    return
  end

  options = opts or {}

  local originalEntryMaker = telescopeMakeEntryModule.gen_from_lsp_symbols(options)

  options.entry_maker = function(line)
    local originalEntryTable = originalEntryMaker(line)

    local displayer = telescopeEntryDisplayModule.create({
      separator = " ",
      items = {
        { width = fileTypeIconWidth },
        { width = 15 },
        { width = 30 },
        { width = nil },
        { remaining = true },
      },
    })

    originalEntryTable.display = function(entry)
      local tail, pathToDisplay = M.getPathAndTail(entry.filename)
      local icon, iconHighlight = telescopeUtilities.get_devicons(tail)

      -- local tail, _ = M.getPathAndTail(entry.filename)
      local tailForDisplay = tail .. " "
      local pathToDisplay = telescopeUtilities.transform_path({
        path_display = { shorten = { num = 2, exclude = { -2, -1 } }, "truncate" },
      }, entry.value.filename)

      return displayer({
        { icon, iconHighlight },
        { entry.symbol_type:lower(), "TelescopeResultsVariable" },
        { entry.symbol_name, "TelescopeResultsConstant" },
        tailForDisplay,
        { pathToDisplay, "TelescopeResultsComment" },
      })
    end

    return originalEntryTable
  end

  -- require('telescope._extensions').manager.coc.workspace_symbols(options)
  require("telescope.builtin").lsp_dynamic_workspace_symbols(options)
end

return M
