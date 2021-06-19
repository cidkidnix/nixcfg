{ lib
, stdenv
, python39Packages
, libusb
, wget
, fetchFromGitHub
}:

python39Packages.buildPythonPackage rec {
    pname = "fusee-interfacee-tk";
    version = "1.0.1";

    src = fetchFromGitHub {
        owner = "nh-server";
        repo = pname;
        rev = "V${version}";
        sha256 = "sha256-ai1TnafzTXUecBpIgAK3BfXKDrK5qCRe9tac+jj9o3k=";
    };

    propagatedBuildInputs = [
        libusb
        python39Packages.tkinter
        python39Packages.pyusb
    ];

    buildPhase = ''
        cp * $out/bin
    '';
}