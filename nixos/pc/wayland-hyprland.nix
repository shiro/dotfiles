{
  config,
  lib,
  pkgs,
  inputs,
  username,
  ...
}:
let
  hyprland_pkg = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  hyprland_cmd = "${hyprland_pkg}/bin/start-hyprland > /dev/null";

  rofi_plugin_blocks = (
    pkgs.rofi-blocks.rofi-blocks.override {
      rofi-unwrapped = pkgs.rofi-unwrapped;
    }
  );
  rofi_package = pkgs.rofi.override { plugins = [ rofi_plugin_blocks ]; };
in
{
  programs.hyprland = {
    package = hyprland_pkg;
    enable = true;
    xwayland.enable = true;
  };
  programs.waybar = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    alacritty # terminal emulator
    hyprpaper # wallpapers for Hyprland
    hyprlock # lockscreen
    hyprpicker
    pavucontrol # pulse audio volume control
    rofi_package # application search
    wofi # application search (wayland)
    dunst # notifications
    brightnessctl # brightness control
    wl-clipboard # clipboard access on wayland
    grim # screenshot utility
    slurp # region selection for scripting
    wf-recorder # screen recording
    ueberzugpp # draw images over TTY
    pulseaudio # pulse CLI
    libnotify # send notifications
    dragon-drop # CLI drag-n-drop
    ripdrag # CLI drag-n-drop
    playerctl # browser media play/pause

    # cursor
    hyprcursor
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
    rose-pine-cursor
  ];

  programs.ydotool.enable = true; # automate wayland tasks

  services.greetd = {
    enable = true;
    restart = true;
    settings = {
      initial_session = {
        command = "${hyprland_cmd}";
        user = "${username}";
      };
      default_session = {
        command = "${hyprland_cmd}";
        user = "${username}";
      };
    };
  };
  services.pipewire.jack.enable = true;

  # reduce blue-light
  location.provider = "geoclue2";
  services.redshift = {
    enable = true;
    brightness = {
      day = "1";
      night = "1";
    };
    temperature = {
      day = 5500;
      night = 3700;
    };
  };

  services.udev.enable = true;
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", MODE="0666", RUN+="${pkgs.brightnessctl}/bin/brightnessctl set 50000"
  '';

  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    nerd-fonts.hack
    nerd-fonts.noto
    # (nerdfonts.override { fonts = [ "Hack" "Noto" ]; })
    carlito
    dejavu_fonts
    ipafont
    kochi-substitute
    source-code-pro
    ttf_bitstream_vera
  ];

  fonts.fontconfig.defaultFonts = {
    monospace = [
      "DejaVu Sans Mono"
      "IPAGothic"
    ];
    sansSerif = [
      "DejaVu Sans"
      "IPAPGothic"
    ];
    serif = [
      "DejaVu Serif"
      "IPAPMincho"
    ];
  };

  environment.sessionVariables = {
    # make electron use wayland
    NIXOS_OZONE_WL = "1";
  };
}
