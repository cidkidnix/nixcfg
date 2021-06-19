{ stdenv
, libnotify
, fetchFromGitHub
, lib
}:

stdenv.mkDerivation {
  name = "mpv-notify-send";

  src = fetchFromGitHub {
    owner = "emilazy";
    repo = "mpv-notify-send";
    rev = "master";
    sha256 = "sha256-EwVkhyB87TJ3i9xJmmZMSTMUKvfbImI1S+y1vgRWbDk=";
  };

  patchPhase = ''
    substituteInPlace notify-send.lua \
      --replace '"notify-send"' '"${libnotify}/bin/notify-send"'
  '';

  installPhase = ''
    mkdir -p $out/share/mpv/scripts
    cp notify-send.lua $out/share/mpv/scripts
  '';

  scriptName = "notify-send.lua";

  meta = with lib; {
    homepage = "https://github.com/emilazy/mpv-notify-send";
    description = "A Lua script for mpv to send notifications with notify-send(1)";
    license = licenses.wtfpl;
    platforms = platforms.all;
    maintainers = with maintainers; [ emily ];
  };
}