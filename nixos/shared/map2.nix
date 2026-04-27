{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.services.map2;
  hyprland_pkg = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  map2_wheel = pkgs.python313.pkgs.buildPythonPackage {
    version = "2.0.20";
    pname = "map2";
    format = "wheel";
    src = ./map2-2.1.1-cp313-cp313-manylinux_2_39_x86_64.whl;
  };

  python_map2_pkg = pkgs.python313.withPackages (
    python-pkgs: with python-pkgs; [
      pip
      map2_wheel
      hidapi
      opencv4
      numpy
      requests
    ]
  );

in
{
  options.services.map2 = {
    enable = lib.mkEnableOption "map2 service";

    mappingScript = lib.mkOption {
      type = lib.types.str;
      default = "/home/shiro/project/mappings/main/macbook2018.py";
      description = "Path to the mapping script to execute";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.map2 = {
      enable = true;
      wantedBy = [ "xsession.target" ];
      partOf = [ "graphical-session.target" ];
      path = with pkgs; [
        python_map2_pkg
        # pkgs.zsh
        hyprland_pkg
        evtest
        procps
        sudo
        libnotify
        grim
        ydotool
        wl-clipboard

        xkbcomp
        xkbutils
        libxkbcommon
      ];

      serviceConfig = {
        ExecStart = "${python_map2_pkg}/bin/python ${cfg.mappingScript}";
        Restart = "always";
        RestartSec = "5s";
      };
    };

    environment.systemPackages = with pkgs; [
      python_map2_pkg
    ];

    services.udev.extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="input"
    '';
  };
}
