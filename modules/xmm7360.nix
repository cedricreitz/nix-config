{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hardware.cellular.xmm7360;
  
  configFile = pkgs.writeText "xmm7360.ini" ''
[xmm7360]
apn=${cfg.apn}
${optionalString (cfg.username != "") "username=${cfg.username}"}
${optionalString (cfg.password != "") "password=${cfg.password}"}
${optionalString (cfg.authType != "") "auth=${cfg.authType}"}

# Network interface configuration
interface=wwan0
metric=${toString cfg.metric}

# Modem configuration
${cfg.extraConfig}
  '';

in {
  options.hardware.cellular.xmm7360 = {
    enable = mkEnableOption "Intel XMM7360 cellular modem support";

    package = mkOption {
      type = types.package;
      default = pkgs.xmm7360-pci-spat;
      description = "The xmm7360-pci-spat package to use";
    };

    apn = mkOption {
      type = types.str;
      default = "internet";
      example = "internet";
      description = ''
        Access Point Name (APN) for your cellular provider.
        Common APNs:
        - Generic: "internet"
        - T-Mobile: "fast.t-mobile.com"
        - Verizon: "vzwinternet"
        - AT&T: "broadband"
        - Vodafone: "internet.vodafone.net"
        - O2: "o2.internet"
      '';
    };

    username = mkOption {
      type = types.str;
      default = "";
      description = "Username for cellular connection (if required by provider)";
    };

    password = mkOption {
      type = types.str;
      default = "";
      description = "Password for cellular connection (if required by provider)";
    };

    authType = mkOption {
      type = types.enum [ "" "pap" "chap" "both" ];
      default = "";
      description = "Authentication type (leave empty for auto-detection)";
    };

    metric = mkOption {
      type = types.int;
      default = 700;
      description = "Network metric for the cellular interface (higher = lower priority)";
    };

    autoStart = mkOption {
      type = types.bool;
      default = false;
      description = "Automatically start the cellular connection on boot";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional configuration options for xmm7360.ini";
    };
  };

  config = mkIf cfg.enable {
    # Add the package to system packages
    environment.systemPackages = [ cfg.package ];

    # Load the kernel module
    boot.kernelModules = [ "xmm7360" ];
    boot.extraModulePackages = [ cfg.package ];

    # Create configuration file
    environment.etc."xmm7360/xmm7360.ini".source = configFile;

    # Add udev rules for device permissions
    services.udev.extraRules = ''
      # XMM7360 cellular modem
      SUBSYSTEM=="wwan", KERNEL=="wwan*", GROUP="networkmanager", MODE="0664"
      SUBSYSTEM=="tty", KERNEL=="ttyXMM*", GROUP="networkmanager", MODE="0664"
      
      # Auto-load module when device is detected
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x7360", RUN+="${pkgs.kmod}/bin/modprobe xmm7360"
    '';

    # Systemd service for automatic connection
    systemd.services.xmm7360-cellular = mkIf cfg.autoStart {
      description = "XMM7360 Cellular Connection";
      after = [ "network.target" ];
      wants = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        Type = "forking";
        ExecStart = "${cfg.package}/bin/xmm7360-connect --daemon";
        ExecStop = "${pkgs.procps}/bin/pkill -f xmm7360";
        Restart = "on-failure";
        RestartSec = "10s";
        User = "root";
        
        # Security settings
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ "/var/lib/xmm7360" "/dev" "/sys" ];
      };
      
      preStart = ''
        # Ensure the module is loaded
        ${pkgs.kmod}/bin/modprobe xmm7360 || true
        
        # Wait for device to be ready
        for i in {1..30}; do
          if [ -e /dev/wwan0at0 ] || [ -e /dev/wwan0xmmrpc0 ]; then
            break
          fi
          sleep 1
        done
      '';
    };

    # NetworkManager integration
    networking.networkmanager.enable = mkDefault true;
    
    # Add users to networkmanager group for device access
    users.groups.networkmanager = {};
  };
}