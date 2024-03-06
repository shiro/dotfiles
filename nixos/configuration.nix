{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      # ./map2.nix
      # inputs.home-manager.nixosModules.default
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  security.sudo.wheelNeedsPassword = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  networking.hostName = "shiro-pc";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  

  # Enable CUPS to print documents.
  # services.printing.enable = true;

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
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    enable = true;
    xwayland.enable = true;
  };
  programs.waybar = {
    enable = true;
  };

  users.defaultUserShell = pkgs.zsh;

  users.users.shiro = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      firefox
      darktable
      figma-linux
      borgbackup
      discord
      betterdiscordctl
    ];
  };

  # home-manager = {
  #   extraSpecialArgs = {inherit inputs;};
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
    # spice-vdagent
    (let map2 = python311.pkgs.buildPythonPackage rec {
      version = "2.0.13";
      pname = "map2";
      format = "wheel";
      src = fetchPypi {
        inherit pname version format;
        sha256 = "51b048efdb8810e812ee5c62b9cc5414d1eb6dbf9bb835b1a0ca2b9fe8e0c22f";
        dist = "cp311";
        python = "cp311";
        abi = "cp311";
        platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
      };
    };
    in python311.withPackages (python-pkgs: [
      map2
      # python-pkgs.pandas
      python-pkgs.requests
    ]))
    ripgrep
    mako
    tmux
    wget
    zathura
    hyprpaper
    rsync
    ueberzugpp
    wl-clipboard
    xclip
    diff-so-fancy
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
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  # services.mpd = {
  #   enable = true;
  #   user = "shiro";
  #   musicDirectory = "/home/shiro/Music";
  #   extraConfig = ''
  #     audio_output {
  #       type    "pipewire"
  #       name    "music_out"
  #       # server "127.0.0.1"
  #     }
  #
  #   playlist_directory   "~/.mpd/playlists"
  #   db_file              "~/.mpd/mpd.db"
  #   log_file             "~/.mpd/mpd.log"
  #   pid_file             "~/.mpd/mpd.pid"
  #   state_fil	     "~/.mpd/state"
  #   sticker_file         "~/.mpd/sticker.sql"
  #   user                 "shiro"
  #   # bind_to_address	     "0.0.0.0"
  #   bind_to_address      "~/.config/mpd/socket"
  #   '';
  #   # systemd feature: only start MPD service upon connection to its socket
  #   # startWhenNeeded = true;
  # };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # DO NOT CHANGE THIS EVER
  system.stateVersion = "23.11"; # Did you read the comment?
}

