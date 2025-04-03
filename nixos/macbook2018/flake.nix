{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    nixpkgs-rofi-blocks.url = "github:edenkras/nixpkgs";
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = ["https://cache.soopy.moe"];
    extra-trusted-public-keys = ["cache.soopy.moe-1:0RZVsQeR+GOh0VQI9rvnHz55nVXkFardDqfm4+afjPo="];
  };

  outputs = { self, nixpkgs, nixpkgs-rofi-blocks, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      overlay-rofi-blocks = final: prev: {
        rofi-blocks = nixpkgs-rofi-blocks.legacyPackages.${prev.system};
      };
    in
    {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [ 
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-rofi-blocks ]; })
            ./configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };

    };
}
