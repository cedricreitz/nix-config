{
  description = "Cedric's multi-target NixOS configs with Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
    in {

      nixosConfigurations = {
        lenovop14s = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./common/configuration.nix
            ./targets/lenovop14s/device-specific.nix
            ./targets/lenovop14s/hardware-configuration.nix
            home-manager.nixosModules.home-manager
          ];
        };

        desktop = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./common/configuration.nix
            ./targets/desktop/device-specific.nix
            ./targets/desktop/hardware-configuration.nix
            home-manager.nixosModules.home-manager
          ];
        };
      };
    };
}