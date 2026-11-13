{
  config,
  lib,
  pkgs,
  inputs,
  username,
  ...
}:

let
  mpdConf = pkgs.writeText "mpd.conf" ''
    audio_output {
      type "pipewire"
      name "music_out"
    }
    music_directory     "/home/${username}/Music"

    playlist_directory   "/home/${username}/.mpd/playlists"
    db_file              "/home/${username}/.mpd/mpd.db"
    log_file             "/home/${username}/.mpd/mpd.log"
    pid_file             "/home/${username}/.mpd/mpd.pid"
    state_file           "/home/${username}/.mpd/state"
    sticker_file         "/home/${username}/.mpd/sticker.sql"

    bind_to_address      "/home/${username}/.config/mpd/socket"
    restore_paused "yes"
  '';
in
{
  systemd.user.services.mpd = {
    enable = true;
    after = [
      "network.target"
      "sound.target"
    ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Environment = "PATH=/home/shiro/bin";
      ExecStart = "${pkgs.mpd}/bin/mpd --no-daemon ${mpdConf}";
      Type = "notify";
    };
  };

  # Keeps the queue topped up with random library tracks (library/shuffle mode).
  # `play` stops it for one-off file playback; `music` starts it again.
  systemd.user.services.ashuffle = {
    enable = true;
    after = [ "mpd.service" ];
    requires = [ "mpd.service" ];
    partOf = [ "mpd.service" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Environment = "MPD_HOST=/home/${username}/.config/mpd/socket";
      ExecStart = "${pkgs.ashuffle}/bin/ashuffle --tweak play-on-startup=no";
      Restart = "on-failure";
      RestartSec = 2;
    };
  };

  # Open audio files with the `play` script (MPD, play once, then the queue empties)
  xdg.mime.defaultApplications = lib.genAttrs [
    "audio/x-wav"
    "audio/wav"
    "audio/vnd.wave"
    "audio/mpeg"
    "audio/mp3"
    "audio/flac"
    "audio/x-flac"
    "audio/ogg"
    "audio/opus"
    "audio/mp4"
    "audio/aac"
    "audio/x-m4a"
  ] (_: "mpd-play.desktop");

  environment.systemPackages = [
    (pkgs.makeDesktopItem {
      name = "mpd-play";
      desktopName = "MPD Play";
      exec = "/home/${username}/bin/play %F";
      terminal = false;
      noDisplay = true;
      mimeTypes = [
        "audio/x-wav"
        "audio/wav"
        "audio/vnd.wave"
        "audio/mpeg"
        "audio/mp3"
        "audio/flac"
        "audio/x-flac"
        "audio/ogg"
        "audio/opus"
        "audio/mp4"
        "audio/aac"
        "audio/x-m4a"
      ];
    })
  ];

  users.users.${username}.packages = with pkgs; [
    mpd # music player daemon
    ncmpcpp # music player client TUI
    mixxc # volume mixer
    ashuffle # shuffle mpd music
    mpc # music player CLI
    puddletag # taging
  ];
}

