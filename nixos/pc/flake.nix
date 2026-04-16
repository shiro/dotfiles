{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # hyprland.url = "github:hyprwm/Hyprland?tag=v0.42.0";
    hyprland.url = "github:hyprwm/Hyprland";
    whisp-away.url = "github:madjinn/whisp-away";
    catppuccin.url = "github:catppuccin/nix";
    # hyprland = {
    #   url = "git+https://github.com/hyprwm/Hyprland?rev=cba1ade848feac44b2eda677503900639581c3f4";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # hyprland = {
    #   type = "git";
    #   url = "https://github.com/hyprwm/Hyprland";
    #   rev = "9a09eac79b85c846e3a865a9078a3f8ff65a9259";
    #   submodules = true;
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nixpkgs-rofi-blocks.url = "github:edenkras/nixpkgs";
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://cache.soopy.moe"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.soopy.moe-1:0RZVsQeR+GOh0VQI9rvnHz55nVXkFardDqfm4+afjPo="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-rofi-blocks,
      nixos-hardware,
      ...
    }@inputs:
    let
      overlay-rofi-blocks = final: prev: {
        rofi-blocks = nixpkgs-rofi-blocks.legacyPackages.${prev.stdenv.hostPlatform.system};
      };
    in
    {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          (
            { ... }:
            {
              nixpkgs.overlays = [ overlay-rofi-blocks ];
            }
          )
          ./configuration.nix
          inputs.catppuccin.nixosModules.catppuccin
          inputs.home-manager.nixosModules.default
        ];
      };

    };
}
