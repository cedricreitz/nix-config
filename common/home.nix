{ config, pkgs, lib, ... }:
{
  home-manager.users.cedricreitz = {
    /* The home.stateVersion option does not have a default and must be set */
    home.stateVersion = "25.05";

    programs.git = {
        enable = true;
        userName  = "Cedric Reitz";
        userEmail = "cedric.reitz@gmail.com";
        extraConfig = {
            init.defaultBranch = "main";
      };
    };
    
    programs.zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [ 
          "git"
        ];
      };
      initContent = lib.mkBefore ''
        if uwsm check may-start; then
          exec uwsm start hyprland-uwsm.desktop
        fi

        # Powerlevel10k
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        source ${../dotfiles/.p10k.zsh}

        # Nix-packaged external plugins
        source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

        # Other
        eval "$(zoxide init zsh)"
      '';
      shellAliases = {
        update = "sudo nixos-rebuild switch --flake ~/repos/nix-config#lenovop14s";
        ls = "lsd";
        cat = "bat";
        cd = "z";
        cl = "clear";
      };
    };


    home.file.".config/hypr" = {
      source = ../dotfiles/.config/hypr;
      recursive = true;
    };
    home.file.".config/rofi" = {
      source = ../dotfiles/.config/rofi;
      recursive = true;
    };
    home.file.".config/waybar" = {
      source = ../dotfiles/.config/waybar;
      recursive = true;
    };

    
  };
}