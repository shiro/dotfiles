{
  pkgs,
  config,
  ...
}:
let
  username = "shiro";
  shared = "${builtins.getEnv "DOTFILES"}/nixos/shared";
in
{
  _module.args = {
    username = username;
  };

  imports = [
    ./hardware-configuration.nix
    "${shared}/general.nix"
    "${shared}/user.nix"

    "${shared}/ime.nix"
    "${shared}/laptop.nix"
    "${shared}/map2.nix"
    "${shared}/music.nix"
    "${shared}/ui-apps.nix"
    "${shared}/wayland-hyprland.nix"
  ];

  services.map2 = {
    enable = true;
    mappingScript = "/home/shiro/project/mappings/main/proart.py";
  };

  boot.kernelPackages = pkgs.linuxPackages_7_0;
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "4199706c";
  boot.zfs.package = pkgs.zfs_2_4;

  services.sanoid = {
    enable = true;
    templates = {
      "default" = {
        hourly = 24;
        daily = 7;
        weekly = 7;
        monthly = 4;
        autosnap = true;
        autoprune = true;
      };
    };
    datasets = {
      "storage/home" = {
        useTemplate = [ "default" ];
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /etc/asusd 0755 root root -"
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # nvidia stuff
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    powerManagement.enable = true; # Required for fine-grained
    powerManagement.finegrained = true; # Enabled for power saving

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true; # Adds 'nvidia-offload' command
      };
      # Bus IDs
      amdgpuBusId = "PCI:0:65:0"; # Integrated AMD GPU
      nvidiaBusId = "PCI:0:64:0";
    };
  };

  # asusctl
  services.asusd.enable = true;

  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      gfxmodeEfi = "2880x1800";
    };
    efi.canTouchEfiVariables = true;
  };

  networking.hostName = "shiro-proart";

  nix.settings = {
    substituters = [
      "https://cache.soopy.moe"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://chaotic-nyx.cachix.org"
      "https://ezkea.cachix.org"
    ];
    trusted-public-keys = [
      "cache.soopy.moe-1:0RZVsQeR+GOh0VQI9rvnHz55nVXkFardDqfm4+afjPo="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "nyx.chaotic.cx-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
    ];
  };

  environment.sessionVariables = {
    # make electron use wayland
    NIXOS_OZONE_WL = "1";
    LOCAL_CONFIG_DIR = "/home/${username}/.local/config";
    XKB_CONFIG_ROOT = "${pkgs.xkeyboard_config}/share/X11/xkb";
  };

  users.users.shiro = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "input"
    ];
    packages = with pkgs; [
      awscli2
    ];
  };

  environment.systemPackages = with pkgs; [
    cloudflared # cloudflare tunnels
  ];

  services.syncthing = {
    enable = true;
    user = "shiro";
    group = "users";
    openDefaultPorts = true;
    dataDir = "/home/shiro";
    configDir = "/home/shiro/.config/syncthing";
    # guiAddress = "0.0.0.0:8384";
    settings = {
      devices = {
        "homebox" = {
          id = "HDV7UR5-FLO23CH-WA2X7XR-CGD5KD6-QCTVNB7-BUPV2WM-LGWFTOH-UIPAMQ4";
        };
      };
      folders = {
        "wiki" = {
          path = "/home/shiro/wiki";
          devices = [ "homebox" ];
        };
      };
    };
  };
  # Don't create default ~/Sync folder
  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";

  networking.firewall.enable = false;
  networking.extraHosts = ''
    127.0.0.1 mac
  '';

  system.stateVersion = "24.05";
}
