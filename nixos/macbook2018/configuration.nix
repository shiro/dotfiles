{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  username = "shiro";
  shared = "${builtins.getEnv "DOTFILES"}/nixos/shared";

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
  _module.args = {
    username = username;
  };

  imports = [
    /etc/nixos/hardware-configuration.nix
    inputs.home-manager.nixosModules.default
    "${shared}/wayland-hyprland.nix"
    "${shared}/ime.nix"
    "${shared}/map2.nix"
  ];

  services.map2 = {
    enable = true;
    mappingScript = "/home/shiro/project/mappings/main/macbook2018.py";
  };

  hardware.firmware = [
    (pkgs.stdenvNoCC.mkDerivation (final: {
      name = "brcm-firmware";
      src = /etc/nixos/firmware/brcm;
      installPhase = ''
        mkdir -p $out/lib/firmware/brcm
        cp ${final.src}/* "$out/lib/firmware/brcm" '';
    }))
  ];

  boot = {
    plymouth.enable = true;
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "udev.log_level=3"
      "systemd.show_status=auto"
    ];
    loader.timeout = 0;
  };
  catppuccin.plymouth.enable = true;

  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      gfxmodeEfi = "2880x1800";
    };
    efi.canTouchEfiVariables = true;
  };
  catppuccin.grub.enable = true;
  catppuccin.tty.enable = true;

  # boot.loader = {
  #   grub = {
  #     enable = true;
  #     efiSupport = true;
  #     device = "/boot";
  #     fsIdentifier = "label";
  #     efiInstallAsRemovable = true;
  #     gfxmodeEfi = "2880x1800";
  #     font = "${pkgs.hack-font}/share/fonts/hack/Hack-Regular.ttf";
  #     fontSize = 36;
  #   };
  # };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useUserPackages = true;
    users = {
      "shiro" = import ./home.nix;
    };
  };

  # to enable docker emulation on m1, use:
  # $ docker run --privileged --rm tonistiigi/binfmt --install all
  # virtualisation.docker.enable = true;

  systemd.user.services.ssh-agent = {
    enable = true;
    wantedBy = [ "default.target" ];
    path = [ pkgs.openssh ];
    serviceConfig = {
      Type = "simple";
      Environment = [
        "SSH_AUTH_SOCK=%t/ssh-agent.socket"
        "DISPLAY=:0"
      ];
      ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a $SSH_AUTH_SOCK";
    };
  };
  # programs.ssh.startAgent = true;

  security.sudo.wheelNeedsPassword = false;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  networking.hostName = "shiro-macbook2018";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # Set your time zone.

  # Select internationalisation properties.
  console = {
    # font = "Lat2-Terminus16";
    # keyMap = "us";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # services.qemuGuest.enable = true;
  # services.spice-vdagentd.enable = true;

  services.ollama = {
    enable = true;
    # acceleration = "cuda";
  };
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

  # programs.direnv = {
  #   enable = true;
  #   silent = true;
  # };

  nix.settings = {
    substituters = [
      "https://cache.soopy.moe"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://chaotic-nyx.cachix.org"
      "https://ezkea.cachix.org"
    ];
    trusted-public-keys = [
      "cache.soopy.moe-1:0RZVsQeR+GOh0VQI9rvnHz55nVXkFardDqfm4+afjPo="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "nyx.chaotic.cx-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
    ];
  };

  programs.zsh = {
    enable = true;
    # initExtra = ''
    # export NIX_LD=$(nix eval --impure --raw --expr 'let pkgs = import <nixpkgs> {}; NIX_LD = pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker"; in NIX_LD')
    # '';
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };
  programs.git.enable = true;

  environment.sessionVariables = {
    # make electron use wayland
    NIXOS_OZONE_WL = "1";
    LOCAL_CONFIG_DIR = "/home/${username}/.local/config";
    XKB_CONFIG_ROOT = "${pkgs.xkeyboard_config}/share/X11/xkb";
  };

  programs.firefox = {
    enable = true;
    preferences = {
      "browser.tabs.hoverPreview.enabled" = false;
      "browser.compactmode.show" = true;
      "browser.search.suggest.enabled" = false;
    };
  };

  users.defaultUserShell = pkgs.zsh;

  users.users.shiro = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "input"
    ];
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
      # irssi
      keepassxc
      mpc
      mpv
      nsxiv
      dragon-drop
      nodejs_22 # node
      pnpm # node package manager
      hub
      yarn
      go
      goimports-reviser
      jq
      unzip
      dex
      xournalpp
      killall
      aichat
      gh
      awscli2
      # libreoffice-qt6-fresh

      chromium
      cached-nix-shell

      # vim deps
      lua51Packages.rocks-nvim
      lua51Packages.lua
      stylua
      lua-language-server
      tree-sitter
      gnumake # needed for nvim plugin build
      gcc # compiler
    ];
  };

  environment.systemPackages = with pkgs; [
    nil # nix language server (nvim can't install it)
    cliphist
    fzf
    gcc
    htop-vim
    bottom
    ranger
    silver-searcher
    yazi

    xkeyboard_config
    libinput
    evtest
    # spice-vdagent
    ripgrep
    mako
    tmux
    wget
    zathura
    rsync
    diff-so-fancy
    highlight
    pmutils
    rclone
    nix-tree
    # bottles # wine emulation organization
    cloudflared # cloudflare tunnels

    xkbcomp
    xkbutils

    libxkbcommon
    xorg.setxkbmap
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
  services.openssh.settings.X11Forwarding = true;
  programs.ssh.forwardX11 = true;
  programs.ssh.setXAuthLocation = true;

  security.rtkit.enable = true;

  # services.pipewire.systemWide = true;

  # services.udev.extraRules = ''
  #   # Allow the 'input' group to manipulate input events
  #   # SUBSYSTEM=="misc", KERNEL=="uinput", MODE="0660", GROUP="input"
  #
  #   # Assign specific input devices to input group
  # '';
  # boot.initrd.services.udev.rules = ''
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="input"
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

  systemd.user.services.waypipe = {
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
      # ExecStartPre = ''
      # ${pkgs.bash}/bin/bash -c "${pkgs.coreutils}/bin/mkdir -p '${cfg.dataDir}' '${cfg.playlistDirectory}'"'';
    };
  };

  services.syncthing = {
    enable = true;
    user = "shiro";
    group = "users";
    openDefaultPorts = true;
    dataDir = "/home/shiro";
    configDir = "/home/shiro/.config/syncthing";
    # guiAddress = "0.0.0.0:8384";
    settings = {
      devices = {
        "homebox" = {
          id = "HDV7UR5-FLO23CH-WA2X7XR-CGD5KD6-QCTVNB7-BUPV2WM-LGWFTOH-UIPAMQ4";
        };
      };
      folders = {
        "wiki" = {
          path = "/home/shiro/wiki";
          devices = [ "homebox" ];
        };
      };
    };
  };
  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true"; # Don't create default ~/Sync folder

  nix = {
    gc = {
      # automatic = true;
      # dates = "weekly";
      # options = "--delete-older-than 10d";
    };
  };

  # laptop battery optimizations
  services.tlp.enable = true;

  # timezone sync
  # services.geoclue2.enable = true;
  # services.automatic-timezoned.enable = true;
  time.timeZone = "Asia/Tokyo";

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

  # networking.wireless.iwd = {
  #   enable = true;
  #   settings.General.EnableNetworkConfiguration = true;
  # };

  # networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];

  networking.firewall.enable = false;
  networking.extraHosts = ''
    127.0.0.1 mac
  '';

  system.stateVersion = "24.05"; # Did you read the comment?
}
