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
      # WWAN special setup
      packages.x86_64-linux.xmm7360-pci = nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/xmm7360-pci {};
      nixosModules.xmm7360 = import ./modules/xmm7360.nix;

      nixosConfigurations = {
        lenovop14s = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./common/configuration.nix
            ./targets/lenovop14s/device-specific.nix
            ./targets/lenovop14s/hardware-configuration.nix
            home-manager.nixosModules.home-manager
            self.nixosModules.xmm7360
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
