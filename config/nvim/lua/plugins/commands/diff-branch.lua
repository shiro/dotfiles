local strings = require("plenary.strings")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local make_entry = require("telescope.make_entry")

return function()
  local opts = {}
  local utils = require("telescope.utils")
  local entry_display = require("telescope.pickers.entry_display")

  local git_command = utils.__git_command
  local get_git_command_output = function(args, opts)
    return utils.get_os_command_output(git_command(args, opts), opts.cwd)
  end
  local format = "%(HEAD)"
    .. "%(refname)"
    .. "%(authorname)"
    .. "%(upstream:lstrip=2)"
    .. "%(committerdate:format-local:%Y/%m/%d %H:%M:%S)"

  local output = get_git_command_output(
    { "for-each-ref", "--perl", "--format", format, "--sort", "-authordate", opts.pattern },
    opts
  )

  local show_remote_tracking_branches = vim.F.if_nil(opts.show_remote_tracking_branches, true)

  local results = {}
  local widths = {
    name = 0,
    authorname = 0,
    upstream = 0,
    committerdate = 0,
  }
  local unescape_single_quote = function(v) return string.gsub(v, "\\([\\'])", "%1") end
  local parse_line = function(line)
    local fields = vim.split(string.sub(line, 2, -2), "''")
    local entry = {
      head = fields[1],
      refname = unescape_single_quote(fields[2]),
      authorname = unescape_single_quote(fields[3]),
      upstream = unescape_single_quote(fields[4]),
      committerdate = fields[5],
    }
    local prefix
    if vim.startswith(entry.refname, "refs/remotes/") then
      if show_remote_tracking_branches then
        prefix = "refs/remotes/"
      else
        return
      end
    elseif vim.startswith(entry.refname, "refs/heads/") then
      prefix = "refs/heads/"
    else
      return
    end
    local index = 1
    if entry.head ~= "*" then index = #results + 1 end

    entry.name = string.sub(entry.refname, string.len(prefix) + 1)
    for key, value in pairs(widths) do
      widths[key] = math.max(value, strings.strdisplaywidth(entry[key] or ""))
    end
    if string.len(entry.upstream) > 0 then widths.upstream_indicator = 2 end
    table.insert(results, index, entry)
  end
  for _, line in ipairs(output) do
    parse_line(line)
  end
  if #results == 0 then return end

  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = 1 },
      { width = widths.name },
      { width = widths.authorname },
      { width = widths.upstream_indicator },
      { width = widths.upstream },
      { width = widths.committerdate },
    },
  })

  local make_display = function(entry)
    return displayer({
      { entry.head },
      { entry.name, "TelescopeResultsIdentifier" },
      { entry.authorname },
      { string.len(entry.upstream) > 0 and "=>" or "" },
      { entry.upstream, "TelescopeResultsIdentifier" },
      { entry.committerdate },
    })
  end

  require("telescope.pickers")
    .new(opts, {
      prompt_title = "branches",
      finder = require("telescope.finders").new_table({
        results = results,
        entry_maker = function(entry)
          entry.value = entry.name
          entry.ordinal = entry.name
          entry.display = make_display
          return make_entry.set_default_entry_mt(entry, opts)
        end,
      }),
      sorter = require("telescope.config").values.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local ret = action_state.get_selected_entry()
          require("diffview").open({ ret.name })
        end)
        return true
      end,
    })
    :find()
end
