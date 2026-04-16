{
  config,
  lib,
  pkgs,
  ...
}:
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc-ut
      fcitx5-gtk
      fcitx5-table-other
      qt6Packages.fcitx5-configtool
      catppuccin-fcitx5
    ];
    fcitx5.waylandFrontend = true;
  };

  # services.xserver.xkb.layout = "rabbit";
  # services.xserver.xkb.extraLayouts.rabbit = {
  #   description = "US layout (rabbit)";
  #   languages = [ "eng" ];
  #   symbolsFile = /home/shiro/.xkb/symbols/rabbit;
  # };

  # services.xserver.enable = true;
  # services.xserver.exportConfiguration = true;
  # services.xserver.xkb = {
  #   layout = "rabbit";
  #   # xkbVariant = "workman,";
  #   # xkbOptions = "grp:win_space_toggle";
  # };
#
}

