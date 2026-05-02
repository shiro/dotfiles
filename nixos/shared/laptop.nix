{
  pkgs,
  username,
  ...
}:
{
  # laptop battery optimizations
  services.tlp.enable = true;

  # ignore lid
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

  # set brigtness on boot
  services.udev.enable = true;
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", MODE="0666", RUN+="${pkgs.brightnessctl}/bin/brightnessctl set 50000"
  '';
}
