{ pkgs, lib, ... }:
{
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
        seahorse
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

    programs.zsh.enable = true;
}