{
  pkgs,
  username,
  inputs,
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
    kitty # terminal emulator
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
    inputs.surge.packages.${pkgs.system}.default # browser download manager
  ];

  home-manager.users.${username} = {
    imports = [
      inputs.whisp-away.nixosModules.home-manager
    ];

    services.whisp-away = {
      enable = true;
      defaultModel = "small.en";
      defaultBackend = "faster-whisper";
    };

    systemd.user.services.surge = {
      Unit = {
        Description = "Surge download manager server";
        After = [ "graphical-session.target" ];
        Wants = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${inputs.surge.packages.${pkgs.system}.default}/bin/surge server --token 12345";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
