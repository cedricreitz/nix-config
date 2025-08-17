{ config, pkgs, ... }:
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
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "zsh-autosuggestions" "zsh-syntax-highlighting" ];
        theme = "powerlevel10k/powerlevel10k";
      };
      shellAliases = {
        update = "sudo nixos-rebuild switch";
        ls = "lsd";
        cat = "bat";
        cd = "z";
        cl = "clear";
      };
      initContent = ''
        [[ -f ./p10k.zsh ]] && source ./p10k.zsh
      '';
    };


  };
}