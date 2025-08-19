{ config, pkgs, lib, ... }:
{
  imports =
    [ 
      ./packages.nix
      ./home.nix
    ];
  system.stateVersion = "25.05";
  boot = {
    loader.systemd-boot.configurationLimit = 5;
    initrd.systemd.enable = true;
    kernelPackages = pkgs.linuxPackages_zen;
    plymouth = {
      enable = true;
      theme = "loader_2";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "loader_2" ];
        })
      ];
    };
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
      "vt.default_red=30,243,166,249,137,245,148,186,88,243,166,249,137,245,148,166"
      "vt.default_grn=30,139,227,226,180,194,226,194,91,139,227,226,180,194,226,173"
      "vt.default_blu=46,168,161,175,250,231,213,222,112,168,161,175,250,231,213,200"
      "psi=1"
      "systemd.unified_cgroup_hierarchy=1"
    ];
    loader.timeout = 0;
  
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };
  
  xdg.portal.enable = true;
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };
  
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };
  console.keyMap = "de";
  
  users.users.cedricreitz = {
    isNormalUser = true;
    description = "Cedric Reitz";
    extraGroups = [ "networkmanager" "wheel" "lxd" ];
    packages = with pkgs; [];
  };
  
  services.getty.autologinUser = "cedricreitz";
  security.sudo.wheelNeedsPassword = false;
  
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
  
  services.gnome.gnome-keyring.enable = true;
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  services.fprintd.enable = true;
  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    liberation_ttf
    cantarell-fonts
  ];

  security.polkit.enable = true;
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "cedricreitz" ];
  };
  
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  
  virtualisation = {
    waydroid.enable = true;
    lxc.enable = true;
  };
}