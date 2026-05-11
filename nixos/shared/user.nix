{
  inputs,
  lib,
  username,
  config,
  ...
}:
{
  options.userPackages = lib.mkOption {
    type = lib.types.listOf lib.types.package;
    default = [ ];
    description = "Additional packages to install for the user";
  };

  config.users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "input"
      "ydotool"
    ];
    packages = config.userPackages;
  };

  config = {
    home-manager = {
      extraSpecialArgs = { inherit inputs; };
      useUserPackages = true;

      users.${username} = {
        home.username = "shiro";
        home.homeDirectory = "/home/shiro";
        home.stateVersion = "25.11";

        # let Home Manager install and manage itself.
        programs.home-manager.enable = true;

        services.udiskie.enable = true; # auto-mount disks
      };
    };
  };
}
