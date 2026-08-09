---@module 'hl'

-- workspaces
hl.workspace_rule({ workspace = 1, monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = 2, monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = 3, monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = 5, monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = 4, monitor = "DP-1" })
hl.workspace_rule({ workspace = 6, monitor = "DP-1", gaps_in = 0, gaps_out = 0 })
hl.workspace_rule({ workspace = 7, monitor = "DP-1" })
hl.workspace_rule({ workspace = 8, monitor = "DP-2" })
hl.workspace_rule({ workspace = 9, monitor = "DP-2" })
hl.workspace_rule({ workspace = 10, monitor = "DP-2" })

hl.monitor({
  output = "desc:Dell Inc. DELL S2722QC 2860J24",
  mode = "3840x2160",
  position = "1080x445",
  scale = 1.6,
  reserved_area = { top = 4, bottom = 0, left = 0, right = 0 },
})

hl.monitor({
  output = "desc:I-O Data Device Inc LDGCWF291SD 13SM000810CM",
  mode = "2560x1080@74.99100",
  position = "0x0",
  scale = 1,
  transform = 1,
})

hl.on("hyprland.start", function() hl.exec_cmd("xrandr --output HDMI-A-1 --primary") end)
