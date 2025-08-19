self: super: {
  modemmanager = super.stdenv.mkDerivation rec {
    pname = "modemmanager";
    version = "master";  # Since we're using a commit from master

    src = super.fetchurl {
      url = "https://gitlab.com/linux-mobile-broadband/ModemManager/-/archive/master/ModemManager-master.tar.gz";
      sha256 = "sha256-eae2e28577c53e8deaa25d46d6032d5132be6b58";
    };

    nativeBuildInputs = [ super.pkg-config super.glib ];

    meta = with super.meta; {
      description = "ModemManager from master branch (GitLab)";
      license = licenses.lgpl21;
      platforms = platforms.linux;
    };
  };
}
