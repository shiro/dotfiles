{ config, lib, pkgs, inputs, ... }:
let
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
  hyprland_pkg = inputs.hyprland.packages.${pkgs.system}.hyprland;
  hyprland_cmd = "${hyprland_pkg}/bin/Hyprland";
  username = "shiro";
  # pkgs.rofi-blocks.rofi-blocks

  rofi-blocks = (pkgs.rofi-blocks.rofi-blocks.override {
    rofi-unwrapped = pkgs.rofi-wayland-unwrapped;
  });
  rofi_custom = pkgs.rofi-wayland.override { plugins = [ rofi-blocks ]; };

  python_custom = let map2 = pkgs.python312.pkgs.buildPythonPackage rec {
    version = "2.0.19";
    pname = "map2";
    format = "wheel";
    src = pkgs.fetchPypi {
      inherit pname version format;
      sha256 = "662a9dcb53a89c0db2c7aa82a3ea0c7a7fc30470c18159edaad632c7f8b89994";
      dist = "cp312";
      python = "cp312";
      abi = "cp312";
      platform = "manylinux_2_17_aarch64.manylinux2014_aarch64";
    };
  };
  in pkgs.python312.withPackages (python-pkgs: with python-pkgs; [
    pip
    map2
  ]);

  mpdConf = pkgs.writeText "mpd.conf" ''
    audio_output {
      type "pipewire"
      name "music_out"
    }
    music_directory     "/home/shiro/Music"

    playlist_directory   "/home/shiro/.mpd/playlists"
    db_file              "/home/shiro/.mpd/mpd.db"
    log_file             "/home/shiro/.mpd/mpd.log"
    pid_file             "/home/shiro/.mpd/mpd.pid"
    state_file	         "/home/shiro/.mpd/state"
    sticker_file         "/home/shiro/.mpd/sticker.sql"

    bind_to_address      "/home/shiro/.config/mpd/socket"
  '';
in
{
  # imports =
  #   [ 
  #     ./hardware-configuration.nix
  #     inputs.home-manager.nixosModules.default
  #   ];
  imports =
    [
      ./hardware-configuration.nix
      inputs.apple-silicon.nixosModules.default
      # inputs.home-manager.nixosModules.default
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  boot.binfmt.emulatedSystems = [ "x86_64-linux" ];
  # to enable docker emulation on m1, use:
  # $ docker run --privileged --rm tonistiigi/binfmt --install all

  #boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  virtualisation.docker.enable = true;
  # services.getty.autologinUser = "shiro";
  services.greetd = {
    enable = true;
    restart = true;
    settings = {
      initial_session = {
        command = "${hyprland_cmd}";
        user = "${username}";
      };
      default_session = {
        # command = "${tuigreet} --greeting 'Welcome to NixOS!' --asterisks --remember --remember-user-session --time -cmd ${hyprland_cmd}";
        # user = "greeter";
        command = "${hyprland_cmd}";
        user = "${username}";
      };
    };
  };


  systemd.user.services.ssh-agent = {
    enable = true;
    wantedBy = [ "default.target" ];
    path = [ pkgs.openssh ];
    serviceConfig = {
      Type = "simple";
      Environment = [
        ''SSH_AUTH_SOCK=%t/ssh-agent.socket''
        ''DISPLAY=:0''
      ];
      ExecStart = ''${pkgs.openssh}/bin/ssh-agent -D -a $SSH_AUTH_SOCK'';
    };
  };

  systemd.user.services.map2 = {
    enable = true;
    wantedBy = [ "xsession.target" ];
    partOf = [ "graphical-session.target" ];
    path = [ pkgs.zsh hyprland_pkg pkgs.evtest pkgs.procps pkgs.killall ];
    serviceConfig = {
      ExecStart = ''/run/wrappers/bin/sudo -E ${python_custom}/bin/python /home/shiro/mappings/main/main.py'';
      Restart = "always";
      RestartSec = "5s";
     };
  };

  security.sudo.wheelNeedsPassword = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;


  sound.enable = true;
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
    };
    asahi = {
      peripheralFirmwareDirectory = /etc/nixos/firmware;
      useExperimentalGPUDriver = true;
      withRust = true;
    };
  };

  networking.hostName = "shiro-pc";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.


  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # Select internationalisation properties.
  console = {
    # font = "Lat2-Terminus16";
    # keyMap = "us";
    useXkbConfig = true; # use xkb.options in tty.
  };


  # services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  programs.zsh.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };
  programs.git.enable = true;

  programs.hyprland = {
    package = hyprland_pkg;
    enable = true;
    xwayland.enable = true;
  };
  programs.waybar = {
   enable = true;
  };

  environment.sessionVariables = {
    # make electron use wayland
    NIXOS_OZONE_WL = "1";
    LOCAL_CONFIG_DIR = "/home/${username}/.local/config";
  };


  services.xserver.enable = true;
  services.xserver.exportConfiguration = true;
  # services.xserver.xkb = {
  #   layout = "rabbit";
  #   # xkbVariant = "workman,";
  #   # xkbOptions = "grp:win_space_toggle";
  # };
  # 
  # services.xserver.xkb.extraLayouts.rabbit = {
  #   description = "US layout (rabbit)";
  #   languages   = [ "eng" ];
  #   symbolsFile = /home/shiro/.xkb/symbols/rabbit;
  # };

  i18n.inputMethod = {
    enabled = "fcitx5";

    fcitx5.waylandFrontend = true;

    fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
        fcitx5-configtool
        fcitx5-with-addons
    ];
  };
  i18n.defaultLocale = "en_US.UTF-8";
  # i18n.supportedLocales = [ "ja_JP.UTF-8/UTF-8" ];


  users.defaultUserShell = pkgs.zsh;

  users.users.shiro = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "input" ];
    packages = with pkgs; [
      ashuffle
      # bandwitch
      #betterdiscordctl
      borgbackup
      # darktable
      # discord
      # fcitx5-config-qt
      # fcitx5-configtool
      # fcitx5
      # fcitx5-lua
      # fcitx5-mozc
      # figma-linux
      firefox
      irssi
      keepassxc
      mpc-cli
      mpv
      nsxiv
      xwaylandvideobridge
      xdragon
      nodejs_22
      nodejs_22.pkgs.pnpm
      yarn
      go
      goimports-reviser
      rustup
      cargo
      jq
      unzip
      dex
      mpd
      xournalpp
      slack-term
      killall
      ncmpcpp
      mixxc
      gh
      awscli2
      libreoffice-qt6-fresh

      qemu
    ];
  };

  # home-manager = {
  #   extraSpecialArgs = { inherit inputs; };
  #   users = {
  #     "shiro" = import ./home.nix;
  #   };
  # };

  environment.systemPackages = with pkgs; [
    alacritty
    cliphist
    fzf
    gcc
    htop-vim
    ranger
    silver-searcher

    libinput
    evtest
    # spice-vdagent
    # (let map2 = python312.pkgs.buildPythonPackage rec {
    #   version = "2.0.19";
    #   pname = "map2";
    #   format = "wheel";
    #   src = fetchPypi {
    #     inherit pname version format;
    #     sha256 = "662a9dcb53a89c0db2c7aa82a3ea0c7a7fc30470c18159edaad632c7f8b89994";
    #     dist = "cp312";
    #     python = "cp312";
    #     abi = "cp312";
    #     platform = "manylinux_2_17_aarch64.manylinux2014_aarch64";
    #   };
    # };
    # in python312.withPackages (python-pkgs: [
    #   map2
    #   # python-pkgs.pandas
    #   python-pkgs.requests
    # ]))
    python_custom
    ripgrep
    mako
    tmux
    wget
    zathura
    hyprpaper
    hyprlock
    rsync
    ueberzugpp
    wl-clipboard
    xclip
    diff-so-fancy
    highlight
    carla
    pavucontrol
    rofi_custom
    pmutils
    wofi
    rclone
    libnotify
    hyprcursor

    xorg.xkbcomp
    xorg.xkbutils
    libxkbcommon
    xorg.setxkbmap

    pkg-config
  ];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  security.rtkit.enable = true;

  services.pipewire.jack.enable = true;
  # services.pipewire.systemWide = true;

  services.udev.extraRules = ''
    # Allow the 'input' group to manipulate input events
    # SUBSYSTEM=="misc", KERNEL=="uinput", MODE="0660", GROUP="input"

    # Assign specific input devices to input group
    # ATTRS{name}=="Gaming Keyboard", SUBSYSTEM=="input", MODE="0644", GROUP="map2"
  '';

  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  #   jack.enable = true;
  # };

  # services.mpd = {
  #   enable = true;
  #   # user = username;
  #   user = "root";
  #   musicDirectory = ''/home/${username}/Music'';
  #   extraConfig = ''
  #   audio_output {
  #     type "alsa"
  #     name "music_out"
  #     # server "127.0.0.1"
  #   }
  #   playlist_directory   "/home/shiro/.mpd/playlists"
  #   db_file              "/home/shiro/.mpd/mpd.db"
  #   log_file             "/home/shiro/.mpd/mpd.log"
  #   pid_file             "/home/shiro/.mpd/mpd.pid"
  #   state_file	         "/home/shiro/.mpd/state"
  #   sticker_file         "/home/shiro/.mpd/sticker.sql"
  #   # user                 "shiro"
  #   # bind_to_address    "0.0.0.0"
  #   bind_to_address      "/home/shiro/.config/mpd/socket"
  #   '';
  #   # systemd feature: only start MPD service upon connection to its socket
  #   # startWhenNeeded = true;
  #   # network.listenAddress = "any";
  # };
  # systemd.services.mpd.environment = {
  #     # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
  #     XDG_RUNTIME_DIR = "/run/user/${toString config.users.users.shiro.uid}";
  # };
  # hardware.pulseaudio.extraConfig = "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1";
  # systemd.services.mpd.serviceConfig.SupplementaryGroups = [ "pipewire" ];

  systemd.user.services.mpd = {
    enable = true;
    # Unit = {
      after = [ "network.target" "sound.target" ];
      # Description = "Music Player Daemon";
    # };

    # Install = {
      wantedBy = [ "default.target" ];
    # };

    # Service = {
      serviceConfig = {
        Environment = "PATH=/home/shiro/bin";
        ExecStart = "${pkgs.mpd}/bin/mpd --no-daemon ${mpdConf}";
        Type = "notify";
      # ExecStartPre = ''
        # ${pkgs.bash}/bin/bash -c "${pkgs.coreutils}/bin/mkdir -p '${cfg.dataDir}' '${cfg.playlistDirectory}'"'';
    };
  };

  # systemd.user.services.fcitx5-daemon = {
  #   enable = true;
  #   partOf = [ "graphical-session.target" ];
  #   wantedBy = [ "graphical-session.target" ];
  #   serviceConfig = {
  #     execStart = "${pkg.fcitx5}/bin/fcitx5";
  #   };
  #   };
  # };

  # systemd.user.sockets.mpd = mkIf cfg.network.startWhenNeeded {
  #   Socket = {
  #     ListenStream = let
  #       listen = if cfg.network.listenAddress == "any" then
  #         toString cfg.network.port
  #       else
  #         "${cfg.network.listenAddress}:${toString cfg.network.port}";
  #     in [ listen "%t/mpd/socket" ];
  #
  #     Backlog = 5;
  #     KeepAlive = true;
  #   };

    # Install = { WantedBy = [ "sockets.target" ]; };
  # };

  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };

  networking.extraHosts =
    ''
    127.0.0.1 mac
    '';

  system.stateVersion = "24.05"; # Did you read the comment?
}
