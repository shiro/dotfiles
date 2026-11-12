{ pkgs, ... }:

{
  # Keep an OpenCode server running so requests never pay for the cold start
  # or the models.dev fetch.
  systemd.user.services.opencode-serve = {
    enable = true;
    description = "OpenCode server";
    after = [ "network.target" ];
    wantedBy = [ "default.target" ];
    path = with pkgs; [
      git
      bash
      coreutils
    ];
    serviceConfig = {
      ExecStart = "${pkgs.opencode}/bin/opencode serve --service";
      Restart = "always";
      RestartSec = 3;
    };
  };

  environment.systemPackages = [ pkgs.opencode ];
}
