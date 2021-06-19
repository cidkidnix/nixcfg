{ lib
, stdenv
, python38Packages
, pkg2zip
, wget
, fetchFromGitHub
}:

python38Packages.buildPythonPackage rec {
    pname = "pynps";
    version = "1.6.2";

    src = fetchFromGitHub {
        owner = "evertonstz";
        repo = pname;
        rev = version;
        sha256 = "sha256-ai1TnafzTXUecBpIgAK3BfXKDrK5qCRe9tac+jj9o3k=";
    };

    propagatedBuildInputs = [
        pkg2zip
        wget
        python38Packages.sqlitedict
        python38Packages.prompt_toolkit
        python38Packages.rich
    ];
}