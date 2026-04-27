{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  username = "shiro";
in
{
  _module.args = {
    username = username;
  };

  imports = [
    ./hardware-configuration.nix
    ../shared/wayland-hyprland.nix
    .../shared/ime.nix
    ./map2.nix
    ./music.nix
  ];

  # Backup the entire config directory
  environment.etc."nixos-config".source = ./.;

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_stable;

  hardware.graphics.enable32Bit = true;
  hardware.bluetooth.enable = true;

  # boot.loader.systemd-boot.enable = true;

  boot = {
    plymouth.enable = true;
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "udev.log_level=3"
      "systemd.show_status=auto"
    ];
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;
  };
  catppuccin.plymouth.enable = true;

  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      gfxmodeEfi = "3840x2160";
    };
    efi.canTouchEfiVariables = true;
  };
  catppuccin.grub.enable = true;
  catppuccin.tty.enable = true;

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

  networking.hostName = "shiro-main";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  console = {
    # font = "Lat2-Terminus16";
    # keyMap = "us";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # services.qemuGuest.enable = true;
  # services.spice-vdagentd.enable = true;

  # services.ollama = {
  #   enable = true;
  #   # acceleration = "cuda";
  # };

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
    LOCAL_CONFIG_DIR = "/home/${username}/.local/config";
    # XKB_CONFIG_ROOT = "${pkgs.xkeyboard_config}/share/X11/xkb";
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

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "input"
      "ydotool"
    ];
    packages = with pkgs; [
      borgbackup # backups
      darktable # image editing
      discord # chat
      betterdiscordctl # discord modding
      # figma-linux # design app
      # irssi
      keepassxc # password manager
      mpv
      nsxiv # image viewer
      nodejs_22 # node
      pnpm # node package manager
      yarn # node package manager
      hub # github CLI
      gh # github CLI
      go # golang
      goimports-reviser
      jq # work with JSON
      unzip # unpack a bunch of formats
      dex # desktop entries
      xournalpp # notes app
      killall # useful command utility
      aichat # ai chat
      awscli2
      # libreoffice-qt6-fresh
      xev
      xrandr
      chromium # browser
      cached-nix-shell # quicker nix shells
      git-absorb # amend commits through history
      moreutils # useful command line utils like 'vipe'

      phrase-cli # translation platform
      imagemagick # image processing

      # vim deps
      lua51Packages.rocks-nvim
      lua51Packages.lua
      stylua
      lua-language-server
      tree-sitter

      black # python formatter
    ];
  };

  environment.systemPackages = with pkgs; [
    davinci-resolve

    nil # nix language server (nvim can't install it)
    cliphist # store and manipulate clipboard history
    fzf # TUI for selecting options
    htop-vim # process viewer
    bottom # process viewer
    silver-searcher # full text search
    yazi # file browser
    gnumake # needed for nvim plugin build
    gcc # compiler

    xkeyboard_config
    # evtest

    ripgrep # faster grep

    tmux # multiplexer
    wget # download files from terminal
    zathura # PDF browser
    rsync # copy files
    xclip
    diff-so-fancy # nicer git diffs
    highlight
    pmutils # power management
    rclone
    nix-tree # TUI for browsing nix derivations
    (bottles.override { removeWarningPopup = true; }) # wine emulation organization
    cloudflared # cloudflare tunnels

    xkbcomp
    xkbutils

    bluez # bluetooth
  ];

  security.rtkit.enable = true;

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
  services.openssh.settings.X11Forwarding = true;
  programs.ssh.forwardX11 = true;
  programs.ssh.setXAuthLocation = true;

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

  # environment.variables = {
  #   # Forces Firefox to use XDG Portals
  #   GTK_USE_PORTAL = "1";
  # };

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

  catppuccin.accent = "blue";
  catppuccin.flavor = "macchiato";

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
    127.0.0.1 pc
  '';

  system.stateVersion = "25.11"; # Did you read the comment?
}
