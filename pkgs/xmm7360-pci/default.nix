{ lib, stdenv, fetchFromGitHub, kernel, kmod, python3Packages }:

stdenv.mkDerivation rec {
  pname = "xmm7360-pci";
  version = "unstable-2025-81-19";

  src = fetchFromGitHub {
    owner = "xmm7360";
    repo = "xmm7360-pci";
    rev = "master";
    sha256 = "sha256-wwm9ELALiJrC54azyJ95Rm3pcGLYzhxEe9mcCUvSVKk=";
  };
  nativeBuildInputs = [ kmod ];
  buildInputs = [ kernel.dev ];

  postPatch = ''
    # Fix tty_write function signature for kernel 6.12+
    sed -i 's/static int xmm7360_tty_write(struct tty_struct \*tty, const unsigned char \*buffer, int count)/static ssize_t xmm7360_tty_write(struct tty_struct *tty, const u8 *buffer, size_t count)/' xmm7360.c
    
    # Fix return type casts
    sed -i 's/return count;/return (ssize_t)count;/g' xmm7360.c
    sed -i 's/return xmm7360_qp_write/return (ssize_t)xmm7360_qp_write/' xmm7360.c
    
    # Fix count comparison
    sed -i 's/if (ret > count)/if (ret > (int)count)/' xmm7360.c
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