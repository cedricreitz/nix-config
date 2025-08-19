{ config, pkgs, lib, inputs.self.nixosModules.xmm7360, ... }:
{
  networking.hostName = "lenovop14s";
  environment.systemPackages = with pkgs; [
    brightnessctl
  ];
  services.xmm7360 = {
    enable = true;
    apn = "internet";
    autoConnect = true;
  };
}