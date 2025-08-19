{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.xmm7360;
  xmm7360-pci = config.boot.kernelPackages.callPackage ../pkgs/xmm7360-pci {};
in {
  options.services.xmm7360 = {
    enable = mkEnableOption "XMM7360 PCI cellular modem driver";
    
    apn = mkOption {
      type = types.str;
      default = "internet";
      description = "APN for O2 Germany (postpaid: 'internet', prepaid: 'pinternet.interkom.de')";
    };
    
    autoConnect = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically connect to cellular network on boot";
    };
  };

  config = mkIf cfg.enable {
    # Add kernel module
    boot.extraModulePackages = [ xmm7360-pci ];
    boot.kernelModules = [ "xmm7360" ];
    
    # Python dependencies for userspace tools
    environment.systemPackages = with pkgs; [
      xmm7360-pci
      python3Packages.pyroute2
      python3Packages.configargparse
    ];
    
  # In modules/xmm7360.nix, replace the udev rules section with:
  services.udev.extraRules = ''
    # XMM7360 modem device permissions for NetworkManager
    SUBSYSTEM=="tty", ATTRS{idVendor}=="8086", ATTRS{idProduct}=="7360", GROUP="networkmanager", MODE="0660"
    KERNEL=="ttyXMM*", GROUP="networkmanager", MODE="0660"
    SUBSYSTEM=="net", ATTRS{idVendor}=="8086", ATTRS{idProduct}=="7360", GROUP="networkmanager", MODE="0660"
    SUBSYSTEM=="wwan", ATTRS{idVendor}=="8086", ATTRS{idProduct}=="7360", GROUP="networkmanager", MODE="0660"
  '';
    
    # NetworkManager configuration for cellular
    networking.networkmanager = {
      enable = true;
      settings = {
        # O2 Germany specific settings
        connection = {
          "ipv6.addr-gen-mode" = "stable-privacy";
          "ipv6.ip6-privacy" = "2";
        };
      };
    };
    
    # Create NetworkManager connection profile for O2 Germany
    environment.etc."NetworkManager/system-connections/MobileBroadband.nmconnection" = mkIf cfg.autoConnect {
      text = ''
        [connection]
        id=MobileBroadband
        type=gsm
        autoconnect=true
        autoconnect-priority=1

        [gsm]
        apn=${cfg.apn}
        number=*99#

        [serial]
        baud=115200

        [ipv4]
        method=auto

        [ipv6]
        method=auto
        addr-gen-mode=stable-privacy
        ip6-privacy=2
      '';
      mode = "0600";
    };
    
    systemd.services.xmm7360-init = {
      description = "Initialize XMM7360 cellular modem";
      after = [ "multi-user.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "xmm7360-init" ''
          for i in {1..30}; do
            if [ -c /dev/ttyXMM0 ]; then
              echo "XMM7360 device found"
              break
            fi
            sleep 1
          done
          
          if [ -c /dev/ttyXMM0 ]; then
            echo "Initializing modem..."
            exit 0
          else
            echo "XMM7360 device not found after 30 seconds"
            exit 1
          fi
        '';
      };
    };
  };
}