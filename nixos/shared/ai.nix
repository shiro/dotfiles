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
      claude-code
    ];
    serviceConfig = {
      ExecStart = "${pkgs.opencode}/bin/opencode serve --service";
      Restart = "always";
      RestartSec = 3;
    };
  };

  # Claude Code's OAuth access token only lives ~8h and is refreshed lazily by
  # the CLI. Tools that read ~/.claude/.credentials.json directly (waybar,
  # opencode quota, ...) break once it lapses. `claude auth status` refreshes
  # it without spending any usage, so poll it every 4h and after boot.
  systemd.user.services.claude-token-refresh = {
    description = "Refresh Claude Code OAuth token";
    after = [ "network-online.target" ];
    path = [ pkgs.claude-code ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.claude-code}/bin/claude auth status --text";
    };
  };
  systemd.user.timers.claude-token-refresh = {
    description = "Periodically refresh Claude Code OAuth token";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnStartupSec = "1min";
      OnCalendar = "0/4:00";
      Persistent = true; # catch up after suspend
    };
  };

  environment.systemPackages = [ pkgs.opencode ];

  environment.sessionVariables = {
    # The service starts before DNS is up, so the first models.dev fetch hangs
    # for its 10s timeout and blocks the first TUI. Use the bundled catalog.
    OPENCODE_DISABLE_MODELS_FETCH = "1";
  };
}
