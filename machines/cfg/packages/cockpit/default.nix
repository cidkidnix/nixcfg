{
  lib,
  stdenv,
  nodejs,
  automake,
  pkgconfig,
  python,
  systemd,
  polkit,
  gtk-doc,
  json-glib,
  krb5,
  nfs-utils,
  pam_krb5,
  linux-pam,
  libxslt,
  libssh,
  intltool,
  gobject-introspection,
  networkmanager,
  xmlto,
  nodePackages,
  fetchzip,
  perlPackages
}:

stdenv.mkDerivation rec {
  pname = "cockpit";
  version = "244.1";

  src = fetchzip {
    url = "https://github.com/cockpit-project/cockpit/releases/download/${version}/cockpit-${version}.tar.xz";
    sha256 = "1fw7qmnwd7m9b4xklm7k15amwha8zy4sxk2a3hpdqgjp919v01a3";
  };


  nativeBuildInputs = [ nodejs automake pkgconfig python ];
  buildInputs = [
    systemd
    polkit
    gtk-doc
    json-glib
    krb5
    nfs-utils
    pam_krb5
    linux-pam
    libxslt
    libssh
    intltool
    gobject-introspection
    networkmanager
    xmlto
    nodePackages.npm
    nodePackages.webpack
    perlPackages.JavaScriptMinifierXS
    perlPackages.FileShareDir
    perlPackages.JSON
  ];

  configureFlags = [
    "--disable-pcp"
    "--disable-doc"
    "--with-systemdunitdir=$(out)/etc/systemd"
  ];

  meta = with stdenv.lib; {
    description = "A sysadmin login session in a web browser";
    homepage = "https://www.cockpit-project.org";
    license = stdenv.lib.licenses.lgpl2;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers;
      [
        thefenriswolf
        baronleonardo
      ];
  };
}