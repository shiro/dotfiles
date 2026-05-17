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
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking = {
    hostName = "homebox";
    interfaces.end0.ipv4.addresses = [
      {
        address = "192.168.1.200";
        prefixLength = 24;
      }
    ];
    defaultGateway = "192.168.1.1";
    nameservers = [
      "8.8.8.8"
      "9.9.9.9"
    ];
  };

  environment.systemPackages = with pkgs; [
    xclip
  ];

  services.syncthing = {
    enable = true;
    user = "shiro";
    group = "users";
    openDefaultPorts = true;
    dataDir = "/home/shiro";
    configDir = "/home/shiro/.config/syncthing";
    settings.gui = {
      user = "shiro";
      password = "verysecret";
    };
    guiAddress = "0.0.0.0:8384";
    settings = {
      devices = {
        "shiro-main" = {
          id = "U7WMKLK-SG7TGEI-GL7WPNH-SRNHJE3-CW7KTZQ-OVXSQAV-TJ6FHXR-GLNOHA7";
        };
        "poco1" = {
          id = "FCW4YWU-WTHALTY-UMJP7CJ-S4B7TQI-5QSV4CO-FCS6GPN-YCWIGEH-LRWSJQB";
        };
        "macbook2018" = {
          id = "K3RTVLW-IPHUON4-GIYAMVL-D54NRUQ-K657RDD-U5VFX4C-ZNOWJIW-5VNPJQI";
        };
        "grandma" = {
          id = "KXL6KTI-NZXY6KF-Q7STMNQ-PWXZ4HG-4K4U7SV-MTDU5AS-HDQRLCA-P3CTUQI";
        };
        "maiko" = {
          id = "N5FFSP3-QCLDAVN-IJHIJYJ-EDC3JJH-2Q6XVQ6-LBFPGTV-XUUMTWL-FBWLSAB";
        };
      };
      folders = {
        "wiki" = {
          path = "/home/shiro/sync/wiki";
          devices = [
            "shiro-main"
            "poco1"
            "macbook2018"
          ];
        };
        "pictures" = {
          path = "/home/shiro/sync/pictures";
          devices = [
            "shiro-main"
            "grandma"
            "maiko"
            "poco1"
          ];
        };
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 8384 ];

  services.cloudflared = {
    enable = true;
    tunnels = {
      "97629df7-5816-4d4c-b3fe-18ba5735f1af" = {
        credentialsFile = "/home/shiro/cloudflared/97629df7-5816-4d4c-b3fe-18ba5735f1af.json";
        ingress = {
          "pi.usagi.io" = "ssh://localhost:22";
        };
        default = "http_status:404";
      };
    };
  };

  networking.extraHosts = ''
    127.0.0.1 pc
    192.168.1.200 homebox
    192.168.1.201 proart
  '';

  system.stateVersion = "24.05";
}
