{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  home-manager.users.cedricreitz = {
    /* The home.stateVersion option does not have a default and must be set */
    home.stateVersion = "18.09";
    programs.git = {
        enable = true;
        userName  = "Cedric Reitz";
        userEmail = "cedric.reitz@gmail.com";
        extraConfig = {
            init.defaultBranch = "main";
        };
    };
  };
}