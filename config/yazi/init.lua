require("bookmarks"):setup({
  last_directory = { enable = false, persist = false, mode = "dir" },
  persist = "all",
  desc_format = "full",
  file_pick_mode = "hover",
  custom_desc_input = false,
  show_keys = false,
  notify = {
    enable = false,
    timeout = 1,
    message = {
      new = "New bookmark '<key>' -> '<folder>'",
      delete = "Deleted bookmark in '<key>'",
      delete_all = "Deleted all bookmarks",
    },
  },
})

require("no-status"):setup()
-- require("git"):setup()

require("searchjump"):setup({
  unmatch_fg = "#716D6A",
  match_str_fg = "white",
  match_str_bg = "none",
  -- first_match_str_fg = "#F5C504",
  first_match_str_bg = "#F5C504",
  label_fg = "#CE830D",
  label_bg = "none",
  -- only_current = false,
  -- show_search_in_statusbar = false,
  -- auto_exit_when_unmatch = false,
  enable_capital_label = false,
  -- mapdata = require("sjch").data,
  -- search_patterns = { "hell[dk]d", "%d+.1080p", "第%d+集", "第%d+话", "%.E%d+", "S%d+E%d+" },
})
