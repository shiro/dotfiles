{ config, lib, pkgs, inputs, ... }:
let
  hyprland_pkg = inputs.hyprland.packages.${pkgs.system}.hyprland;
  hyprland_cmd = "${hyprland_pkg}/bin/Hyprland";
  username = "shiro";
  # pkgs.rofi-blocks.rofi-blocks

  rofi-blocks = (pkgs.rofi-blocks.rofi-blocks.override {
    rofi-unwrapped = pkgs.rofi-wayland-unwrapped;
  });
  rofi_custom = pkgs.rofi-wayland.override { plugins = [ rofi-blocks ]; };

  # python_custom = let map2 = pkgs.python312.pkgs.buildPythonPackage rec {
  #   version = "2.0.19";
  #   pname = "map2";
  #   format = "wheel";
  #   src = pkgs.fetchPypi {
  #       inherit pname version format;
  #       sha256 = "af1fb04fb753fcd8a213c96279cc32c4e378a1f74a6250fb814f3ca3c5caf69b";
  #       dist = "cp312";
  #       python = "cp312";
  #       abi = "cp312";
  #       platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
  #   };
  # };
  # in pkgs.python312.withPackages (python-pkgs: with python-pkgs; [
  #   pip
  #   map2
  # ]);

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
  imports =
    [
      /etc/nixos/hardware-configuration.nix
      inputs.home-manager.nixosModules.default
      "${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }}/apple/t2"
    ];

  hardware.firmware = [
    (pkgs.stdenvNoCC.mkDerivation (final: {
                                   name = "brcm-firmware";
                                   src = /etc/nixos/firmware/brcm;
                                   installPhase = ''
                                   mkdir -p $out/lib/firmware/brcm
                                   cp ${final.src}/* "$out/lib/firmware/brcm" '';
    }))
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.efi.efiSysMountPoint = "/boot"; # make sure to change this to your EFI partition!

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
  virtualisation.docker.enable = true;

  services.greetd = {
    enable = true;
    restart = true;
    settings = {
      initial_session = {
        command = "${hyprland_cmd}";
        user = "${username}";
      };
      default_session = {
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
  # programs.ssh.startAgent = true;

  # systemd.user.services.map2 = {
  #   enable = true;
  #   wantedBy = [ "xsession.target" ];
  #   partOf = [ "graphical-session.target" ];
  #   path = [ pkgs.zsh hyprland_pkg pkgs.evtest pkgs.procps pkgs.killall ];
  #   serviceConfig = {
  #     # Environment = [
  #       # ''VIRTUAL_ENV=/home/shiro/project/map2/venv'' ];
  #     # ExecStart = ''/run/wrappers/bin/sudo -E ${python_custom}/bin/python /home/shiro/project/mappings/next/macbook2018.py'';
  #     ExecStart = ''/run/wrappers/bin/sudo -E /home/shiro/project/map2/venv/bin/python /home/shiro/project/mappings/next/macbook2018.py'';
  #     Restart = "always";
  #     RestartSec = "5s";
  #    };
  # };

  security.sudo.wheelNeedsPassword = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
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
  services.logind.lidSwitchExternalPower = "ignore";

  # programs.direnv = {
  #   enable = true;
  #   silent = true;
  # };

  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
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
    XKB_CONFIG_ROOT = "${pkgs.xkeyboard_config}/share/X11/xkb";
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
      # irssi
      keepassxc
      mpc-cli
      mpv
      nsxiv
      xdragon
      nodejs_22
      nodejs_22.pkgs.pnpm
      hub
      yarn
      go
      goimports-reviser
      cargo
      jq
      unzip
      dex
      mpd
      xournalpp
      killall
      ncmpcpp
      mixxc
      gh
      awscli2
      # libreoffice-qt6-fresh
      xorg.xev
      stylua
      lua-language-server

      # screenshot
      grim
      slurp
      hyprpicker
      chromium
      cached-nix-shell

      # branchctl
      # suyu.packages.x86_64-linux.suyu
      ryujinx
    ];
  };

  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    nerd-fonts.hack
    nerd-fonts.noto
    # (nerdfonts.override { fonts = [ "Hack" "Noto" ]; })
  ];

  environment.systemPackages = with pkgs; [
    alacritty
    cliphist
    fzf
    gcc
    htop-vim
    ranger
    silver-searcher
    brightnessctl

    xkeyboard_config
    libinput
    evtest
    # spice-vdagent
    # (let map2 = python312.pkgs.buildPythonPackage rec {
    #   version = "2.0.19";
    #   pname = "map2";
    #   format = "wheel";
    #   src = fetchPypi {
    #     inherit pname version format;
    #     sha256 = "af1fb04fb753fcd8a213c96279cc32c4e378a1f74a6250fb814f3ca3c5caf69b";
    #     dist = "cp312";
    #     python = "cp312";
    #     abi = "cp312";
    #     platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
    #   };
    # };
    # python312.withPackages (python-pkgs: [
    #   python-pkgs.requests
    # ])
    # python_custom
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
    # carla
    pavucontrol
    rofi_custom
    pmutils
    wofi
    rclone
    libnotify
    wf-recorder
    nix-tree
    pulseaudio # pulse CLI
    # bottles # wine emulation organization

    # cursor
    hyprcursor
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
    rose-pine-cursor
    nwg-look

    xorg.xkbcomp
    xorg.xkbutils
    libxkbcommon
    xorg.setxkbmap

    sox # needed for gp.nvim (AI)
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
  services.openssh.forwardX11 = true;
  programs.ssh.forwardX11 = true;
  programs.ssh.setXAuthLocation = true;

  security.rtkit.enable = true;

  services.pipewire.jack.enable = true;
  # services.pipewire.systemWide = true;

  # services.udev.extraRules = ''
  #   # Allow the 'input' group to manipulate input events
  #   # SUBSYSTEM=="misc", KERNEL=="uinput", MODE="0660", GROUP="input"
  #
  #   # Assign specific input devices to input group
  #   # ATTRS{name}=="Gaming Keyboard", SUBSYSTEM=="input", MODE="0644", GROUP="map2"
  # '';

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
    after = [ "network.target" "sound.target" ];
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
        "homebox" = { id = "HDV7UR5-FLO23CH-WA2X7XR-CGD5KD6-QCTVNB7-BUPV2WM-LGWFTOH-UIPAMQ4"; };
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
    after = [ "network.target" "sound.target" ];
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
  networking.extraHosts =
    ''
    127.0.0.1 mac
    '';

  system.stateVersion = "24.05"; # Did you read the comment?
}
