{ config, pkgs, lib, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  boot = {
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
      "binder.devices=binder,hwbinder,vndbinder"
    ];
    loader.timeout = 0;
  
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

  };
  xdg.portal.enable = true;
  networking.hostName = "lenovop14s";
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
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };
  services.getty.autologinUser = "cedricreitz";
  security.sudo.wheelNeedsPassword = false;
  programs.git.enable = true;
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "1password-gui"
    "1password"
    "1password-cli"
    "vscode"
    "google-chrome"
    "discord"
    "apple_cursor"
  ];

  environment.systemPackages = with pkgs; [
    kitty
    hyprlock
    waybar
    hyprpaper
    swaynotificationcenter
    vscode
    apple-cursor
    nwg-look
    rofi-wayland
    zoxide
    lsd
    bat
    xfce.thunar
    gtk-engine-murrine
    hyprpolkitagent
    google-chrome
    discord
    graphite-gtk-theme
    plymouth
    catppuccin-papirus-folders
    kdePackages.qtwayland
    libsForQt5.qtwayland
    kdePackages.qt6ct
    libsForQt5.qt5ct           
    xcursor-pro
    goxlr-utility
    materia-kde-theme
    ranger
    unzip
    python314
    lzip
  ];
  
  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };

  services.fprintd.enable = true;

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

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "25.05";

}
