---@module 'hl'

local home = os.getenv("HOME")

hl.env("PATH", home .. "/.cargo/bin:" .. os.getenv("PATH"))
hl.env("SSH_AUTH_SOCK", os.getenv("XDG_RUNTIME_DIR") .. "/ssh-agent.socket")
hl.env("MPD_HOST", home .. "/.config/mpd/socket")
hl.env("HYPRCURSOR_THEME", "rose-pine-hyprcursor")

-- exec-once = sleep 0.2 && hyprlock
hl.config({
  input = {

    -- kb_rules = "evdev",
    -- kb_rules = "",
    -- kb_model = "pc105",
    -- kb_model = "",
    -- kb_layout = "rabbit",
    -- kb_variant = "",
    -- kb_options = "",
    -- kb_file = home .. "/.xkb/symbols/rabbit",
    -- kb_file = "/home/shiro/tmp/foo/current_layout.xkb",

    follow_mouse = 2,
    float_switch_override_focus = 0,
    touchpad = {
      natural_scroll = false,
      scroll_factor = 0.1,
    },
    sensitivity = 0,
    -- -1.0 - 1.0, 0 means no modification.
    repeat_delay = 220,
    -- repeat_rate = 50
  },
})

hl.device({
  name = "wacom-cintiq-pro-16-pen",
  transform = 0,
  output = "DP-2",
})

hl.device({
  name = "wacom-cintiq-pro-16-touch-finger",
  transform = 0,
  output = "DP-2",
})

hl.device({
  name = "wacom-cintiq-pro-16-touch-finger-1",
  transform = 0,
  output = "DP-2",
})

hl.config({
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    mouse_move_focuses_monitor = false,
    enable_anr_dialog = false,
  },
})

hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 8,
    border_size = 1,
    -- layout = dwindle
    layout = "scrolling",
    -- layout = hy3
    col = {
      active_border = { colors = { "rgba(8aadf4ee)", "rgba(7dc4e4ee)" }, angle = 45 },
      inactive_border = "rgba(494d64aa)",
    },
  },
})

hl.config({
  cursor = {
    -- no_warps = 1
  },
})

-- unscale XWayland

hl.config({
  xwayland = {
    force_zero_scaling = true,
  },
})

hl.config({
  decoration = {
    rounding = 2,
    blur = {
      enabled = true,
      size = 3,
      passes = 1,
    },
  },
})

hl.config({
  animations = {
    enabled = false,
  },
})

hl.config({
  scrolling = {
    column_width = 0.5,
  },
})

hl.config({
  dwindle = {
    preserve_split = true,
    force_split = 2,
  },
})

hl.window_rule({
  name = "discord",
  match = {
    class = "discord",
  },
  no_initial_focus = true,
  workspace = "4 silent",
})

hl.window_rule({
  name = "darktable",
  match = {
    class = "Darktable",
  },
  workspace = 8,
})

hl.window_rule({
  name = "keepass",
  match = {
    class = "org.keepassxc.KeePassXC",
  },
  float = true,
  size = "monitor_w*0.8 monitor_h*0.9",
  center = true,
})

-- Guild Wars 2
-- windowrule = workspace special silent, match:class steam_proton, match:title negative:Guild Wars 2, match:float 1

-- scroll through existing workspaces with SUPER + scroll
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- move focus with CAPS + HJKL
hl.bind("SUPER + CTRL + ALT + SHIFT + H", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + CTRL + ALT + SHIFT + J", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + CTRL + ALT + SHIFT + K", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + CTRL + ALT + SHIFT + L", hl.dsp.focus({ direction = "right" }))

-- move focus to workspace
hl.bind("SUPER + ALT + SHIFT + A", hl.dsp.focus({ workspace = 1 }))
hl.bind("SUPER + ALT + SHIFT + S", hl.dsp.focus({ workspace = 2 }))
hl.bind("SUPER + ALT + SHIFT + D", hl.dsp.focus({ workspace = 3 }))
hl.bind("SUPER + ALT + SHIFT + Q", hl.dsp.focus({ workspace = 4 }))
hl.bind("SUPER + ALT + SHIFT + W", hl.dsp.focus({ workspace = 5 }))
hl.bind("SUPER + ALT + SHIFT + E", hl.dsp.focus({ workspace = 6 }))
hl.bind("SUPER + ALT + SHIFT + R", hl.dsp.focus({ workspace = 7 }))
hl.bind("SUPER + ALT + SHIFT + Z", hl.dsp.focus({ workspace = 8 }))
hl.bind("SUPER + ALT + SHIFT + X", hl.dsp.focus({ workspace = 9 }))
hl.bind("SUPER + ALT + SHIFT + C", hl.dsp.focus({ workspace = 10 }))
-- move window to workspace
hl.bind("SUPER + SHIFT + A", hl.dsp.window.move({ workspace = 1 }))
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = 2 }))
hl.bind("SUPER + SHIFT + D", hl.dsp.window.move({ workspace = 3 }))
hl.bind("SUPER + SHIFT + Q", hl.dsp.window.move({ workspace = 4 }))
hl.bind("SUPER + SHIFT + W", hl.dsp.window.move({ workspace = 5 }))
hl.bind("SUPER + SHIFT + E", hl.dsp.window.move({ workspace = 6 }))
hl.bind("SUPER + SHIFT + R", hl.dsp.window.move({ workspace = 7 }))
hl.bind("SUPER + SHIFT + Z", hl.dsp.window.move({ workspace = 8 }))
hl.bind("SUPER + SHIFT + X", hl.dsp.window.move({ workspace = 9 }))
hl.bind("SUPER + SHIFT + C", hl.dsp.window.move({ workspace = 3 }))
hl.bind("SUPER + SHIFT + C", hl.dsp.window.move({ workspace = 10 }))
-- move in direction
-- bind = SUPER ALT, H, movewindow, l
-- bind = SUPER ALT, J, movewindow, d
-- bind = SUPER ALT, K, movewindow, u
-- bind = SUPER ALT, L, movewindow, r
-- move/resize windows with SUPER + LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + S", hl.dsp.group.toggle())
hl.bind("SUPER + Space", hl.dsp.window.cycle_next())
hl.bind("SUPER + SHIFT + Space", hl.dsp.window.float())
hl.bind("SHIFT + Tab", hl.dsp.group.next({ forward = false }))
hl.bind("SUPER + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + D", hl.dsp.window.fullscreen())
hl.bind("SUPER + T", hl.dsp.window.move({ workspace = "special" }))
hl.bind("SUPER + SHIFT + T", hl.dsp.workspace.toggle_special(nil))
hl.bind("CTRL + ALT + Backspace", hl.dsp.exit())
-- bind = , F2, exec, ~/bin/escape-map2
-- apps
hl.bind("SUPER + Return", hl.dsp.exec_cmd("kitty tmux"))
hl.bind("SUPER + Backspace", hl.dsp.exec_cmd("kitty"))
hl.bind("SUPER + Prior", hl.dsp.exec_cmd("firefox"))
hl.bind("SUPER + ALT + SHIFT + P", hl.dsp.exec_cmd("~/bin/omnibar-rs"))
hl.bind("ALT + F11", hl.dsp.exec_cmd("~/bin/toggle-tray"))
hl.bind("CTRL + SHIFT + Next", hl.dsp.exec_cmd("grim-| wl-copy"))
hl.bind("ALT + Next", hl.dsp.exec_cmd("hyprpicker| wl-copy"))
-- bind = SUPER,       F10, exec, hyprctl keyword monitor "DP-2,3840x2160,1080x720,1.25"
-- bind = SUPER SHIFT, F10, exec, hyprctl keyword monitor "DP-2,1920x1080,1080x720,1"
-- bind = SUPER,       F9, exec, hyprctl keyword monitor "DP-1,3840x2160,1080x1500,1.333333"
-- bind = SUPER SHIFT, F9, exec, hyprctl keyword monitor "DP-1,disabled"
-- bind = SUPER,       F8, exec, hyprctl keyword monitor "HDMI-A-1,2560x1080,0x0,1,transform,1"
-- bind = SUPER SHIFT, F8, exec, hyprctl keyword monitor "HDMI-A-1,disabled"
-- tab + num
-- bind = SUPER ALT SHIFT, 1, exec, ide-term
hl.bind("SUPER + ALT + SHIFT + 2", hl.dsp.exec_cmd("grim -g $(slurp -d)-| wl-copy"))
hl.bind("SUPER + ALT + SHIFT + 3", hl.dsp.exec_cmd("hyprlock"))
hl.bind(
  "SUPER + ALT + SHIFT + 4",
  hl.dsp.exec_cmd("terminal-capture start -fs " .. home .. "/Videos/termcap-$(date +'%Y-%m-%d-%H%M%S.termdump')")
)
-- bind = SUPER ALT SHIFT, 5, exec, genki
hl.bind("SUPER + ALT + SHIFT + 6", hl.dsp.exec_cmd("[fullscreen] xournalpp"))
-- screenshot (selection)
hl.bind(
  "SUPER + ALT + SHIFT + 7",
  hl.dsp.exec_cmd(
    'sleep 2 && grim -g "$(slurp -d)" - | wl-copy && wl-paste > '
      .. home
      .. "/Pictures/screenshots/$(date +'%Y-%m-%d-%H%M%S.png')"
  )
)
-- screenshot
hl.bind(
  "SUPER + ALT + SHIFT + 8",
  hl.dsp.exec_cmd(
    "sleep 2 && grim - | wl-copy && wl-paste > " .. home .. "/Pictures/screenshots/$(date +'%Y-%m-%d-%H%M%S.png')"
  )
)

-- record screen
hl.bind("SUPER+ALT+SHIFT+9", hl.dsp.exec_cmd("sleep 2 && ~/bin/screencap"))
-- bind = ,f13, exec, firefox
-- bind = SUPER ALT SHIFT, j, exec, (cd ~/project/voice; nix-shell --run "python main.py")
hl.bind("ALT+g", hl.dsp.exec_cmd("whisp-away start"))
hl.bind("ALT+g", hl.dsp.exec_cmd("whisp-away stop"), { repeating = true })
hl.bind("SUPER+ALT+SHIFT+k", hl.dsp.exec_cmd("zsh -ic ~/bin/wiki"))
hl.bind("SUPER+ALT+SHIFT+Y", hl.dsp.exec_cmd("keepassxc"))
-- system
hl.bind("CTRL+SHIFT+0", hl.dsp.exec_cmd("systemctl --user restart map2"))
hl.bind("SUPER+ALT+SHIFT+bracketleft", hl.dsp.exec_cmd("~/bin/clipboard-rotate"))
hl.bind("ALT+Backspace", hl.dsp.exec_cmd("pkill Hyprland"))
-- audio
hl.bind("SUPER+SHIFT+9", hl.dsp.exec_cmd("~/bin/audio-output toggle"))
hl.bind("SUPER+SHIFT+8", hl.dsp.exec_cmd("~/.cargo/bin/mixxc"))
-- music
hl.bind("SUPER+SHIFT+h", hl.dsp.exec_cmd("~/bin/music prev"))
hl.bind("SUPER+SHIFT+l", hl.dsp.exec_cmd("~/bin/music next"))
hl.bind("SUPER+SHIFT+j", hl.dsp.exec_cmd("~/bin/music library"))
hl.bind("SUPER+SHIFT+k", hl.dsp.exec_cmd("~/bin/music toggle"))
hl.bind("SUPER+SHIFT+semicolon", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("SUPER+ALT+h", hl.dsp.exec_cmd("~/bin/music backward"))
hl.bind("SUPER+ALT+l", hl.dsp.exec_cmd("~/bin/music forward"))
hl.bind("SUPER+ALT+j", hl.dsp.exec_cmd("~/bin/music volume-down"))
hl.bind("SUPER+ALT+k", hl.dsp.exec_cmd("~/bin/music volume-up"))

hl.window_rule({
  name = "ueberzugpp",
  match = {
    class = "ueberzugpp.*",
  },
  float = true,
  no_initial_focus = true,
  no_shadow = true,
  border_size = 0,
})

-- local config

-- source = $LOCAL_CONFIG_DIR/hypr/hyprland.conf -> requires manual conversion
-- pcall(require, os.getenv("LOCAL_CONFIG_DIR") .. "/hypr/hyprland")

-- import local overrides
local config_path = home .. "/.local/config/hypr/?.lua"
package.path = config_path .. ";" .. package.path
pcall(require, "hyprland")

-- Autostart
hl.on("hyprland.start", function()
  hl.exec_cmd("hyprctl eval 'hl.dispatch(hl.dsp.focus({ workspace = \"2\" }))'")

  hl.exec_cmd("hyprpaper -c " .. home .. "/.local/config/hypr/hyprpaper.conf")
  hl.exec_cmd("systemctl --user restart map2")
  -- hl.exec_cmd("sleep 5 && waybar > ~/output.txt 2>&1")
  hl.exec_cmd("waybar")
  hl.exec_cmd("sleep 5 && keepassxc")
  hl.exec_cmd("sleep 5 && ~/bin/better-discord")
  hl.exec_cmd("sleep 10 && ashuffle --tweak play-on-startup=no")
  hl.exec_cmd("sleep 20 && fcitx5")
  hl.exec_cmd("sleep 20 && udiskie")
  hl.exec_cmd("sleep 20 && wl-paste --watch cliphist store")
  hl.exec_cmd("wl-paste --watch cliphist store")
  hl.exec_cmd("[workspace 2 silent] ~/bin/al tmux")
  hl.exec_cmd("[workspace 3 silent] firefox")
  hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
  hl.exec_cmd("~/.profile")
end)
