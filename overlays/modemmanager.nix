self: super: {
  modemmanager = super.stdenv.mkDerivation rec {
    pname = "modemmanager";
    version = "master";

    src = super.fetchurl {
      url = "https://gitlab.com/linux-mobile-broadband/ModemManager/-/archive/master/ModemManager-master.tar.gz";
      sha256 = "sha256-GX9xsCzENyd3Gkkw4dAp+0GlzB26HeK7y1/QfIhF/7w=";
    };

    nativeBuildInputs = [
      super.pkg-config
      super.glib
      super.meson_0_59
      super.ninja
      super.gcc
    ];

    buildInputs = [
      super.dbus
      super.libgudev
      super.systemd
      super.polkit
      super.libmbim
      super.libqmi
      super.bash-completion
      super.gobject-introspection
    ];

    mesonFlags = [
      "-Dauto_features=enabled"
      "-Dwrap_mode=nodownload"
      "-Dqmi=enabled"
      "-Dmbim=enabled"
      "-Dqrtr=enabled"
      "-Dsystemd_suspend_resume=false"
      "-Dgtk_doc=true"
      "-Dpolkit=strict"
    ];

    meta = {
      description = "ModemManager from master branch (GitLab) with Polkit support";
      license = super.lib.licenses.lgpl21;
      platforms = [ "x86_64-linux" "aarch64-linux" ];
    };
  };
}
