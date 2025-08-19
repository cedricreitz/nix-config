{ pkgs, lib, ... }:
{
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "1password-gui"
        "1password"
        "1password-cli"
        "vscode"
        "google-chrome"
        "discord"
    ];
    environment.systemPackages = with pkgs; [
        #desktop experience
        kitty
        hyprpaper
        hyprlock
        waybar
        rofi-wayland
        swaynotificationcenter
        hyprpolkitagent
        nwg-look
        adwaita-icon-theme
        xfce.thunar
        graphite-gtk-theme
        gtk-engine-murrine
        catppuccin-papirus-folders
        kdePackages.qtwayland
        libsForQt5.qtwayland
        kdePackages.qt6ct
        libsForQt5.qt5ct           
        materia-kde-theme

        #terminal experience
        zoxide
        lsd
        zsh-powerlevel10k
        zsh-autosuggestions
        zsh-syntax-highlighting

        #utility
        seahorse
        plymouth
        goxlr-utility
        wl-clipboard
        fastfetch

        #generics
        python3Packages.python python3Packages.pyserial python3Packages.configargparse
        python313
        python313Packages.pyroute2
        python313Packages.configargparse
        python313Packages.pyserial
        unzip
        lzip

        #programs
        vscode
        discord
        google-chrome
        waydroid
    ];
}