{ lib, stdenv, fetchFromGitHub, kernel, kmod, python3Packages, linuxPackages, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "xmm7360-pci-spat";
  version = "unstable-2024-12-01";

  src = fetchFromGitHub {
    owner = "SimPilotAdamT";
    repo = "xmm7360-pci-spat";
    rev = "master";
    sha256 = "sha256-T+yJqHzf5gj8r/z4MrN+ZBDr2kfUNEVZEf3eFvGcJKg=";
  };

  nativeBuildInputs = [ kmod makeWrapper ];
  buildInputs = [
    kernel.dev
    python3Packages.pyserial
    python3Packages.configargparse
    python3Packages.pyroute2
    python3Packages.dbus-python
  ];

  postPatch = ''
    # Add kernel version compatibility header
    sed -i '1i#include <linux/version.h>' xmm7360.c

    # Fix hrtimer API for kernel 6.16+
    sed -i '/hrtimer_init(&xn->deadline, CLOCK_MONOTONIC, HRTIMER_MODE_REL);/c\
#if LINUX_VERSION_CODE >= KERNEL_VERSION(6,16,0)\
\thrtimer_setup(&xn->deadline, xmm7360_net_deadline_cb, CLOCK_MONOTONIC, HRTIMER_MODE_REL);\
#else\
\thrtimer_init(&xn->deadline, CLOCK_MONOTONIC, HRTIMER_MODE_REL);\
\txn->deadline.function = xmm7360_net_deadline_cb;\
#endif' xmm7360.c
  
   # Patch the source tree (not the install path)
  for f in rpc/*.py; do
    substituteInPlace "$f" --replace "/etc/xmm7360" "/etc/xmm7360/xmm7360.ini"
  done
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

    # Create wrapper scripts for RPC utilities
    mkdir -p $out/bin
    for f in $out/lib/xmm7360-spat/rpc/*.py; do
      scriptname=$(basename "$f" .py)
      makeWrapper ${python3Packages.python.interpreter} $out/bin/xmm7360-$scriptname \
        --add-flags "$f" \
        --prefix PYTHONPATH : "${python3Packages.makePythonPath [ 
          python3Packages.pyserial 
          python3Packages.configargparse 
          python3Packages.pyroute2
          python3Packages.dbus-python
        ]}"
    done

    # Add status helper
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
    homepage = "https://github.com/SimPilotAdamT/xmm7360-pci-spat";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
