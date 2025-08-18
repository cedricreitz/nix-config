{ config, pkgs, lib, ... }:
{
  networking.hostName = "lenovop14s";
  environment.systemPackages = with pkgs; [
    brightnessctl
  ];
}