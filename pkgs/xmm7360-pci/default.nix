{ lib, stdenv, fetchFromGitHub, kernel, kmod, python3Packages }:

stdenv.mkDerivation rec {
  pname = "xmm7360-pci";
  version = "unstable-2024-01-15";

  src = fetchFromGitHub {
    owner = "xmm7360";
    repo = "xmm7360-pci";
    rev = "master";
    sha256 = "sha256-wwm9ELALiJrC54azyJ95Rm3pcGLYzhxEe9mcCUvSVKk=";
  };

  # Add the patch for kernel 6.12 compatibility
  patches = [ ./kernel-6.12-compat.patch ];

  nativeBuildInputs = [ kmod ];
  buildInputs = [ kernel.dev ];

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
    
    # Install Python utilities
    mkdir -p $out/bin $out/lib/python3/dist-packages
    cp -r rpc $out/lib/python3/dist-packages/ 2>/dev/null || true
    
    # Create wrapper scripts for the Python tools
    for script in *.py; do
      if [ -f "$script" ]; then
        scriptname=$(basename "$script" .py)
        cat > $out/bin/xmm7360-$scriptname << EOF
#!/usr/bin/env bash
export PYTHONPATH="$out/lib/python3/dist-packages:\$PYTHONPATH"
exec ${python3Packages.python}/bin/python3 $out/lib/python3/dist-packages/$script "\$@"
EOF
        chmod +x $out/bin/xmm7360-$scriptname
      fi
    done
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "PCI driver for Fibocom L850-GL / Intel XMM7360 cellular modem";
    homepage = "https://github.com/xmm7360/xmm7360-pci";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}