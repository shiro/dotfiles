{
  config,
  pkgs,
  username,
  ...
}:

# Self-hosted GitHub Actions runner for shiro/dict (label "fujipod"): builds the production image and
# deploys it to the cloud server (.github/workflows/deploy.yml in the repo).
#
# Registration: put a registration token into /home/shiro/fujipod-ci/.token, then rebuild/restart:
#   gh api -X POST repos/shiro/dict/actions/runners/registration-token -q .token > ~/fujipod-ci/.token
# The token is used once; it's needed again only when the runner options below change.
let
  root = "/home/${username}/fujipod-ci";
in
{
  services.github-runners.fujipod = {
    enable = true;
    url = "https://github.com/shiro/dict";
    name = "fujipod-ci";
    tokenFile = "${root}/.token";
    workDir = "${root}/_work";
    user = username;
    group = "users";
    replace = true;
    # only "fujipod": jobs for any self-hosted runner (old workflows on other branches) never run here
    noDefaultLabels = true;
    extraLabels = [ "fujipod" ];
    extraPackages = with pkgs; [
      config.virtualisation.docker.package
      openssh
      gnutar
      gzip
      findutils
      gnused
    ];
    serviceOverrides = {
      # workDir is in /home
      ProtectHome = false;
      # needs the docker group for the docker socket
      PrivateUsers = false;
    };
  };
}
