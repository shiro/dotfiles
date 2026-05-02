{
  pkgs,
  inputs,
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
    /etc/nixos/hardware-configuration.nix
    inputs.home-manager.nixosModules.default
    "${shared}/general.nix"

    "${shared}/ime.nix"
    "${shared}/laptop.nix"
    "${shared}/map2.nix"
    "${shared}/music.nix"
    "${shared}/ui-apps.nix"
    "${shared}/wayland-hyprland.nix"
  ];

  services.map2 = {
    enable = true;
    mappingScript = "/home/shiro/project/mappings/main/macbook2018.py";
  };

  hardware.firmware = [
    (pkgs.stdenvNoCC.mkDerivation (final: {
      name = "brcm-firmware";
      src = /etc/nixos/firmware/brcm;
      installPhase = ''
        mkdir -p $out/lib/firmware/brcm
        cp ${final.src}/* "$out/lib/firmware/brcm" '';
    }))
  ];

  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      gfxmodeEfi = "2880x1800";
    };
    efi.canTouchEfiVariables = true;
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useUserPackages = true;
    users = {
      "shiro" = import ./home.nix;
    };
  };

  networking.hostName = "shiro-macbook2018";

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
