{
 stdenv,
 lib,
 fetchFromGitHub,
 cmake,
 libusb,
 protobuf,
 openssl,
 boost,
 git
}:

stdenv.mkDerivation rec {
  pname = "aasdk";
  version = "master";

  src = fetchFromGitHub {
    owner = "f1xpl";
    repo = pname;
    rev = "${version}";
    sha256 = "sha256-jooLfsPQ16K7bMIlaaAE2L/B3XEc3covTy0k3d/nfCM=";
  };

  patches = [
    (builtins.fetchurl {
      url = "https://aur.archlinux.org/cgit/aur.git/plain/promise.patch?h=aasdk-git";
      sha256 = "1ghjr726jvd4rxh7cf7xzj181k6b5hqq73cimcpx0zhrkj75hlv7";
    })
    ./usbhub.patch
  ];

  nativeBuildInputs = [
    cmake
    boost
    git
  ];

  buildInputs = [
    libusb
    protobuf
    openssl
  ];

  buildPhase = ''
    ls -la ./aasdk_proto
    mkdir -p $out/{lib,include}
    mkdir -p $out/include/aasdk_proto
    mkdir -pv aasdk_build
    cd aasdk_build
    cmake ../
    cd ..
    make
    cd aasdk_proto/
    make
    cd ..
  '';

  cmakeFlags = [ "-DCMAKE_BUILD_TYPE=Release" ];

  installPhase = ''
    ls -la ./
    cp ../lib/*.so $out/lib/
    cp aasdk_proto/*.pb* $out/include/aasdk_proto
    cp -Rv ../include/f1x $out/include
  '';
}