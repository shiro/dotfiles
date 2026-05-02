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
    ./hardware-configuration.nix

    "${shared}/general.nix"

    "${shared}/discord.nix"
    "${shared}/gaming.nix"
    "${shared}/ime.nix"
    "${shared}/laptop.nix"
    "${shared}/map2.nix"
    "${shared}/music.nix"
    "${shared}/ui-apps.nix"
    "${shared}/wayland-hyprland.nix"
  ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_stable;

  hardware.graphics.enable32Bit = true;
  hardware.bluetooth.enable = true;

  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      gfxmodeEfi = "3840x2160";
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

  networking.hostName = "shiro-main";

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "input"
      "ydotool"
    ];
    packages = with pkgs; [
      darktable # image editing
      go # golang
      awscli2
    ];
  };

  environment.systemPackages = with pkgs; [
    davinci-resolve
    xkeyboard_config # TODO move or remove
    cloudflared # cloudflare tunnels
    bluez # bluetooth
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
  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true"; # Don't create default ~/Sync folder

  networking.firewall.enable = false;
  networking.extraHosts = ''
    127.0.0.1 pc
  '';

  system.stateVersion = "25.11";
}
