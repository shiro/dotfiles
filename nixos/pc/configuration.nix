{
  pkgs,
  ...
}:
let
  username = "shiro";
  shared = "${builtins.getEnv "PWD"}/../shared";
in
{
  _module.args = {
    username = username;
  };

  imports = [
    ./hardware-configuration.nix

    "${shared}/general.nix"
    "${shared}/user.nix"

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

  hardware.bluetooth.enable = true;
  hardware.amdgpu.opencl.enable = true;

  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      gfxmodeEfi = "3840x2160";
    };
    efi.canTouchEfiVariables = true;
  };

  services.map2 = {
    enable = true;
    mappingScript = "/home/shiro/mappings/main/pc.py";
  };

  networking.hostName = "shiro-main";

  userPackages =
    with pkgs;
    pkgs.lib.mkAfter [
      darktable # image editing
      go # golang
      awscli2
    ];

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
    guiAddress = "0.0.0.0:8384";
    settings.gui = {
      user = "shiro";
      password = "verysecret";
    };
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
  networking.firewall.allowedTCPPorts = [ 8384 ];

  networking.extraHosts = ''
    127.0.0.1 pc
    192.168.1.200 homebox
    192.168.1.201 proart
  '';

  system.stateVersion = "25.11";
}
