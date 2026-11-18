{ pkgs, username, ... }:

{
  virtualisation.docker.enable = true;

  # cap the BuildKit build cache (least recently used goes first), it otherwise grows with every build
  virtualisation.docker.daemon.settings.builder.gc = {
    enabled = true;
    defaultKeepStorage = "20GB";
  };

  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  # Expose buildx to docker CLIs that aren't the Nix-wrapped one (e.g. standalone
  # binaries), which only discover plugins via ~/.docker/cli-plugins.
  home-manager.users.${username} = {
    home.file.".docker/cli-plugins/docker-buildx".source =
      "${pkgs.docker-buildx}/libexec/docker/cli-plugins/docker-buildx";
  };
}
