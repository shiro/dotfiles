{ pkgs, username, ... }:

{
  virtualisation.docker.enable = true;

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
