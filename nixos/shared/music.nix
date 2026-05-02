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

  users.users.${username}.packages = with pkgs; [
    mpd # music player daemon
    ncmpcpp # music player client TUI
    mixxc # volume mixer
    ashuffle # shuffle mpd music
    mpc # music player CLI
    puddletag # taging
  ];
}

