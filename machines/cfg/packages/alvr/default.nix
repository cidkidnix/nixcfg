{ lib, stdenv, fetchFromGitHub, rustPlatform, pkg-config, alsaLib, openssl, glib, ffmpeg-full
, cairo, pango, atk, gdk-pixbuf, gtk3, vulkan-headers, vulkan-loader
, clangStdenv, llvmPackages, clang, clang-tools, libunwind, clang_12, makeWrapper, chromium }:

with rustPlatform;

buildRustPackage rec {
  pname = "alvr";
  version = "15.2.1";

  src = fetchFromGitHub {
    owner = "alvr-org";
    repo = "ALVR";
    rev = "v${version}";
    sha256 = "sha256-v7nbzDedKcibksSmhPI4v3ZMbEvXVTrhGJjnNILs6RY=";
  };

  patches = [ ./0001-change-alvr-dir-path.patch ./0002-disable-crash-log.patch ];

  cargoSha256 = "sha256-e293bYGcFR8DjVdnajFoFfrF7WsHqNBfsYL0vcqT3PE=";

  buildInputs = [
    alsaLib
    openssl
    glib
    ffmpeg-full
    cairo
    pango
    atk
    gdk-pixbuf
    gtk3
    vulkan-headers
    vulkan-loader
    clang
    libunwind
    makeWrapper
  ];

  nativeBuildInputs = [ pkg-config clang-tools clang_12 ];

  LIBCLANG_PATH = "${llvmPackages.libclang}/lib";
  cargoBuildFlags = "-p alvr_server -p alvr_launcher -p alvr_vulkan-layer";

  doCheck = false;
  buildType = "debug";

  buildPhase = ''
    cargo xtask build-server --release
  '';

  installPhase = ''
    installPhaseTarget=target/x86_64-unknown-linux-gnu/$cargoBuildType
    mkdir -p $out/{bin,share/vulkan/explicit_layer.d,share/alvr/bin/linux64,lib}
    cp $installPhaseTarget/alvr_launcher $out/bin

    substituteInPlace alvr/vulkan-layer/layer/alvr_x86_64.json --replace "../../../lib64/" "$out/lib/"
    # This file references lib64 but /pkgs/build-support/setup-hooks/move-lib64.sh will take care of that for us.
    cp alvr/vulkan-layer/layer/alvr_x86_64.json $out/share/vulkan/explicit_layer.d
    cp $installPhaseTarget/libalvr_vulkan_layer.so $out/lib

    cp alvr/xtask/server_release_template/driver.vrdrivermanifest $out/share/alvr
    # SteamVR expects this to be in this relative path for x86_64-linux, which is the only platform ALVR supports
    cp $installPhaseTarget/libalvr_server.so $out/share/alvr/bin/linux64/driver_alvr_server.so

    cp -r alvr/legacy_dashboard $out/share/alvr/dashboard

    wrapProgram $out/bin/alvr_server --prefix ALCRO_BROWSER_PATH=${chromium}/bin/chromium
  '';

  meta = with lib; {
    description = "Stream VR games from your PC to your headset over the network";
    homepage = "https://alvr-org.github.io";
    platforms = [ "x86_64-linux" ];
    license = licenses.mit;
    maintainers = [ maintainers.ronthecookie ];
  };
}
