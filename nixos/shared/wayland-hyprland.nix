{
  pkgs,
  inputs,
  username,
  ...
}:
let
  hyprland_pkg = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  hyprland_cmd = "${hyprland_pkg}/bin/start-hyprland > /dev/null";
in
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  boot = {
    plymouth.enable = true;
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "udev.log_level=3"
      "systemd.show_status=auto"
    ];
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 3;
  };

  programs.hyprland = {
    package = hyprland_pkg;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    enable = true;
    xwayland.enable = true;
  };
  programs.waybar = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    hyprpaper # wallpapers for Hyprland
    hyprlock # lockscreen

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

  systemd.user.services.ssh-agent = {
    enable = true;
    wantedBy = [ "default.target" ];
    path = [ pkgs.openssh ];
    serviceConfig = {
      Type = "simple";
      Environment = [
        "SSH_AUTH_SOCK=%t/ssh-agent.socket"
        "DISPLAY=:0"
      ];
      ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a $SSH_AUTH_SOCK";
    };
  };

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

  home-manager.users.${username} = {
    imports = [
      inputs.catppuccin.homeModules.catppuccin
    ];

    qt = {
      enable = true;
      style.name = "kvantum";
      platformTheme.name = "kvantum";
    };

    catppuccin.kvantum.assertStyle = true;
    catppuccin.kvantum.enable = true;
    catppuccin.kvantum.apply = true;
  };

  catppuccin.plymouth.enable = true;
  catppuccin.grub.enable = true;
  catppuccin.tty.enable = true;
  catppuccin.accent = "blue";
  catppuccin.flavor = "macchiato";

  # services.kanshi = {
  #   enable = true;
  #   systemdTarget = "xdg-desktop-portal-hyprland.service";
  #   profiles = {
  #     laptop = {
  #       outputs = [{
  #         criteria = "eDP-1";
  #         scale = 2.0;
  #       }];
  #       exec = "notify-send laptop";
  #     };
  #     work = {
  #       outputs = [
  #         {
  #           criteria = "eDP-1";
  #           position = "auto-down";
  #           scale = 2.0;
  #         }
  #         {
  #           criteria = "DP-4";
  #           position = "auto-up";
  #           scale = 1.6;
  #         }
  #       ];
  #       exec = "notify-send work";
  #       exec wlr-randr --output eDP-1 --right-of HDMI-A-1
  #     };
  #   };
  # };
}
