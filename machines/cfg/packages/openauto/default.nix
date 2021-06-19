{
  lib,
  stdenv,
  aasdk,
  qt5,
  pulseaudio,
  gst_all_1,
  rtaudio,
  cmake,
  fetchFromGitHub,
  wrapQtAppsHook,
  boost,
  protobuf,
  libusb
}:

stdenv.mkDerivation rec {
  pname = "openauto";
  version = "master";

  src = fetchFromGitHub { 
    owner = "f1xpl";
    repo = pname;
    rev = "${version}";
    sha256 = "sha256-kyXv0xDK5aAlTQTP0cBz+QRdvXi5iEIn2JqJ+xpj9C4=";
  };

  nativeBuildInputs = [
   cmake
   wrapQtAppsHook
   boost
  ];

  buildInputs = [
      aasdk
      pulseaudio
      gst_all_1.gst-libav
      gst_all_1.gst-plugins-bad
      rtaudio
      qt5.qtconnectivity
      qt5.qtmultimedia
      libusb
  ];

  cmakeFlags = [ "-DCMAKE_BUILD_TYPE=Release" 
                 "-DRPI3_BUILD=FALSE"
                 "-DLIBUSB_1_INCLUDE_DIR=${libusb.dev}/include/libusb-1.0"
                 "-DProtobuf_LIBRARIES=${protobuf}/lib/libprotobuf.so"
                 "-DProtobuf_INCLUDE_DIR=${protobuf}/include"
                 "-DAASDK_INCLUDE_DIRS=${aasdk}/include"  
                 "-DAASDK_LIBRARIES=${aasdk}/lib/libaasdk.so" 
                 "-DAASDK_PROTO_INCLUDE_DIRS=${aasdk}/include/aasdk_proto"
                 "-DAASDK_PROTO_LIBRARIES=${aasdk}/lib/libaasdk_proto.so"
  ];

  buildPhase = ''
    mkdir -p $out/{bin,lib,include}
    mkdir -p openauto_build
    cd openauto_build
    cmake  ../
    cd ..
    make
  '';

  installPhase = ''
    ls -la openauto_build
    cp ../bin/autoapp $out/bin/autoapp
    cp ../bin/btservice $out/bin/btservice
  '';
}