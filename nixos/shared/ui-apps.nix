{
  pkgs,
  username,
  ...
}:
let
  rofi_plugin_blocks = (
    pkgs.rofi-blocks.rofi-blocks.override {
      rofi-unwrapped = pkgs.rofi-unwrapped;
    }
  );
  rofi_package = pkgs.rofi.override { plugins = [ rofi_plugin_blocks ]; };
in
{
  programs.firefox = {
    enable = true;
    preferences = {
      "browser.tabs.hoverPreview.enabled" = false;
      "browser.compactmode.show" = true;
      "browser.search.suggest.enabled" = false;
    };
  };

  users.users.${username}.packages = with pkgs; [
    alacritty # terminal emulator
    keepassxc # password manager
    mpv # video player
    xournalpp # notes app
    chromium # browser
    hyprpicker # color picker
    wf-recorder # screen recording
    pavucontrol # pulse audio volume control
    dunst # notifications
    libnotify # send notifications
    playerctl # browser media play/pause
    ripdrag # CLI drag-n-drop
    dragon-drop # CLI drag-n-drop
    wofi # application search (wayland)
    brightnessctl # brightness control
    wl-clipboard # clipboard access on wayland
    grim # screenshot utility
    slurp # region selection for scripting
    ueberzugpp # draw images over TTY
    pulseaudio # pulse CLI
    rofi_package # application search
  ];
}
