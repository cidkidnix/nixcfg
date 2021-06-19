{ 
  lib, 
  stdenv, 
  fetchFromGitHub, 
  python3 
}:

stdenv.mkDerivation rec {
    pname = "pkg2zip";
    version = "master";

    src = fetchFromGitHub {
        owner = "lusid1";
        repo = pname;
        rev = "master";
        sha256 = "sha256-sirvaA+1fQIrQC4CMZU30hYDuH8+7YhqQfdWkxhQWEo=";
    };

    buildInputs = [ python3 ];

    makeFlags = [ "PREFIX=$(out)" ];
    postUnpack = ''
        mkdir -p $out/bin
    '';
    installPhase = ''
        cp pkg2zip $out/bin/pkg2zip
        cp *.py $out/bin/
    '';
}
