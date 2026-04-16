{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  hyprland_pkg = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  map2_wheel = pkgs.python313.pkgs.buildPythonPackage rec {
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
    ];

    serviceConfig = {
      ExecStart = "${python_map2_pkg}/bin/python /home/shiro/mappings/main/pc.py";
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
}
