{ lib, stdenv, fetchFromGitHub, kernel, kmod, python3Packages }:

stdenv.mkDerivation rec {
  pname = "xmm7360-pci-spat";
  version = "unstable-2024-12-01";

  src = fetchFromGitHub {
    owner = "SimPilotAdamT";
    repo = "xmm7360-pci-spat";
    rev = "master";
    sha256 = "sha256-T+yJqHzf5gj8r/z4MrN+ZBDr2kfUNEVZEf3eFvGcJKg="; # Update with: nix-prefetch-url --unpack https://github.com/SimPilotAdamT/xmm7360-pci-spat/archive/master.tar.gz
  };

  nativeBuildInputs = [ kmod ];
  buildInputs = [ kernel.dev python3Packages.python python3Packages.pyserial ];

  # The SPAT fork should already have kernel 6.12+ compatibility
  # but add fallback fixes just in case
  postPatch = ''
    # Make configuration more generic if sample exists
    if [ -f xmm7360.ini.sample ]; then
      substituteInPlace xmm7360.ini.sample \
        --replace "o2.internet" "internet" \
        --replace "O2" "Generic Provider"
    fi
  '';

  makeFlags = [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=${placeholder "out"}"
  ];

  buildPhase = ''
    runHook preBuild
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$(pwd) modules
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    
    # Install kernel module
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/extra
    cp *.ko $out/lib/modules/${kernel.modDirVersion}/extra/
    
    # Install Python utilities and RPC tools
    mkdir -p $out/lib/xmm7360-spat
    cp -r rpc $out/lib/xmm7360-spat/ 2>/dev/null || true
    cp *.py $out/lib/xmm7360-spat/ 2>/dev/null || true
    
    # Install configuration files
    mkdir -p $out/etc/xmm7360
    if [ -f xmm7360.ini.sample ]; then
      cp xmm7360.ini.sample $out/etc/xmm7360/xmm7360.ini.example
    fi
    
    # Create wrapper scripts for the Python tools
    mkdir -p $out/bin
    
    # Main connection script
    cat > $out/bin/xmm7360-connect << 'EOF'
#!/usr/bin/env bash
set -e

SCRIPT_DIR="$out/lib/xmm7360-spat"
CONFIG_DIR="/etc/xmm7360"
USER_CONFIG_DIR="$HOME/.config/xmm7360"

# Check for configuration
if [ -f "$USER_CONFIG_DIR/xmm7360.ini" ]; then
    CONFIG_FILE="$USER_CONFIG_DIR/xmm7360.ini"
elif [ -f "$CONFIG_DIR/xmm7360.ini" ]; then
    CONFIG_FILE="$CONFIG_DIR/xmm7360.ini"
else
    echo "No configuration file found. Please create one at:"
    echo "  $USER_CONFIG_DIR/xmm7360.ini or $CONFIG_DIR/xmm7360.ini"
    echo "Use $out/etc/xmm7360/xmm7360.ini.example as a template"
    exit 1
fi

export PYTHONPATH="$SCRIPT_DIR:$PYTHONPATH"
cd "$SCRIPT_DIR"

echo "Starting XMM7360 cellular connection..."
exec ${python3Packages.python}/bin/python3 "$SCRIPT_DIR/xmm7360.py" "$@"
EOF
    chmod +x $out/bin/xmm7360-connect
    
    # RPC utility script
    cat > $out/bin/xmm7360-rpc << 'EOF'
#!/usr/bin/env bash
SCRIPT_DIR="$out/lib/xmm7360-spat"
export PYTHONPATH="$SCRIPT_DIR:$PYTHONPATH"
exec ${python3Packages.python}/bin/python3 "$SCRIPT_DIR/rpc/rpc.py" "$@"
EOF
    chmod +x $out/bin/xmm7360-rpc
    
    # Status check script
    cat > $out/bin/xmm7360-status << 'EOF'
#!/usr/bin/env bash
echo "=== XMM7360 Cellular Modem Status ==="
echo

# Check if module is loaded
if lsmod | grep -q xmm7360; then
    echo "✓ Kernel module loaded"
else
    echo "✗ Kernel module not loaded"
    echo "  Load with: sudo modprobe xmm7360"
fi

# Check for device files
if ls /dev/wwan* >/dev/null 2>&1; then
    echo "✓ Device files present:"
    ls -la /dev/wwan* | sed 's/^/  /'
else
    echo "✗ No device files found"
fi

# Check network interface
if ip link show wwan0 >/dev/null 2>&1; then
    echo "✓ Network interface wwan0 exists"
    ip addr show wwan0 | grep -E "(inet|state)" | sed 's/^/  /'
else
    echo "✗ Network interface wwan0 not found"
fi

# Check for running processes
if pgrep -f xmm7360 >/dev/null 2>&1; then
    echo "✓ XMM7360 processes running:"
    pgrep -f xmm7360 -l | sed 's/^/  /'
else
    echo "✗ No XMM7360 processes running"
fi
EOF
    chmod +x $out/bin/xmm7360-status
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "PCI driver for Fibocom L850-GL / Intel XMM7360 cellular modem (SPAT fork with kernel 6.12+ support)";
    longDescription = ''
      This is a maintained fork of the xmm7360-pci driver that provides support for
      Intel XMM7360-based cellular modems (like Fibocom L850-GL) on newer Linux kernels.
      
      The SPAT (SimPilotAdamT) fork includes fixes for kernel 6.12+ compatibility and
      improved stability. It supports any cellular provider - just configure your APN
      in the configuration file.
    '';
    homepage = "https://github.com/SimPilotAdamT/xmm7360-pci-spat";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}