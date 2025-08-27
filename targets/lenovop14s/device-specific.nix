{ config, pkgs, lib, ... }:
{

  networking.hostName = "lenovop14s";
  environment.systemPackages = with pkgs; [
    brightnessctl
    modem-manager-gui
    networkmanagerapplet
  ];

  networking.modemmanager.enable = true;

}