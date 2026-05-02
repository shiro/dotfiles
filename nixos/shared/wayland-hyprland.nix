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
  programs.hyprland = {
    package = hyprland_pkg;
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
}
