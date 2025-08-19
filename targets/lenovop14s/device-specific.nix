{ config, pkgs, lib, ... }:
let
  modemmanagerOverlay = import ./modemmanager-overlay.nix;
in
{

  networking.hostName = "lenovop14s";
  environment.systemPackages = with pkgs; [
    brightnessctl
    modemmanager
  ];

  nixpkgs.overlays = [ modemmanagerOverlay ];
  systemd.services.modemmanager = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
  };
}