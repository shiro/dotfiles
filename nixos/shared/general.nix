{
  pkgs,
  username,
  ...
}:
{
  # Backup the entire config directory
  environment.etc."nixos-config".source = ./..;

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
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  nixpkgs.config.allowUnfree = true;

  console.useXkbConfig = true;

  security.sudo.wheelNeedsPassword = false;
  security.rtkit.enable = true;

  time.timeZone = "Asia/Tokyo";

  # i18n.supportedLocales = [ "ja_JP.UTF-8/UTF-8" ];
  i18n.defaultLocale = "en_US.UTF-8";

  networking.networkmanager.enable = true;

  environment.sessionVariables = {
    LOCAL_CONFIG_DIR = "/home/${username}/.local/config";
    NIXPKGS_ALLOW_UNFREE = "1";
  };

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
  programs.neovim.vimAlias = true;

  programs.git.enable = true;

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
  services.openssh.settings.X11Forwarding = true;
  programs.ssh.forwardX11 = true;
  programs.ssh.setXAuthLocation = true;

  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true"; # Don't create default ~/Sync folder

  users.users.${username}.packages = with pkgs; [
    cached-nix-shell # quicker nix shells
    nix-tree # TUI for browsing nix derivations
    borgbackup # backups
    hub # github CLI
    gh # github CLI
    git-absorb # amend commits through history
    jq # work with JSON
    aichat # ai chat
    killall # useful command utility
    phrase-cli # translation platform
    unzip # unpack a bunch of formats
    dex # desktop entries
    nsxiv # image viewer
    imagemagick # image processing
    moreutils # useful command line utils like 'vipe'
    bottom # process viewer
    silver-searcher # full text search
    ripgrep # faster grep
    yazi # file browser
    fzf # TUI for selecting options
    cliphist # store and manipulate clipboard history
    rclone # copy files
    rsync # copy files
    pmutils # power management
    zathura # PDF browser
    tmux # multiplexer
    wget # download files from terminal
    diff-so-fancy # nicer git diffs
    nodejs_22 # node
    pnpm # node package manager
    yarn # node package manager
    dragon-drop # drag and drop
    p7zip # work with archives
    zip # work with archives

    xrandr # set X11 display settings
    xkbcomp
    xkbutils

    # vim deps
    lua51Packages.rocks-nvim
    lua51Packages.lua
    stylua
    lua-language-server
    tree-sitter
    nil # nix language server
    highlight
    gnumake
    gcc

    black # python formatter
  ];
}
