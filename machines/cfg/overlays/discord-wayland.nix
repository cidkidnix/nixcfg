final: prev: rec {
  discord-wayland-system = prev.callPackage mkDiscord (rec {
    pname = "discord";
    version = "0.0.15";
    binaryName = "Discord";
    desktopName = "Discord";
    src = prev.fetchurl {
      url = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
      sha256 = "sha256-re3pVOnGltluJUdZtTlSeiSrHULw1UjFxDCdGj/Dwl4=";
    };
    isWayland = true;
    extraOptions = [
      "--enable-vulkan"
      "--ignore-gpu-blocklist"
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
    ];
  });
  mkDiscord =
    { pname
    , version
    , src
    , binaryName
    , desktopName
    , isWayland ? false
    , extraOptions ? [ ]
    , autoPatchelfHook
    , makeDesktopItem
    , lib
    , stdenv
    , wrapGAppsHook
    , alsaLib
    , at-spi2-atk
    , at-spi2-core
    , atk
    , cairo
    , cups
    , dbus
    , electron
    , expat
    , fontconfig
    , freetype
    , gdk-pixbuf
    , glib
    , gtk3
    , libcxx
    , libdrm
    , libnotify
    , libpulseaudio
    , libuuid
    , libX11
    , libXScrnSaver
    , libXcomposite
    , libXcursor
    , libXdamage
    , libXext
    , libXfixes
    , libXi
    , libXrandr
    , libXrender
    , libXtst
    , libxcb
    , mesa
    , nspr
    , nss
    , pango
    , systemd
    , libappindicator-gtk3
    , libdbusmenu
    , nodePackages
    }:
    stdenv.mkDerivation rec {
      inherit pname version src;

      nativeBuildInputs = [
        nodePackages.asar
        alsaLib
        autoPatchelfHook
        cups
        libdrm
        libuuid
        libXdamage
        libX11
        libXScrnSaver
        libXtst
        libxcb
        mesa.drivers
        nss
        wrapGAppsHook
      ];

      dontWrapGApps = true;

      libPath = lib.makeLibraryPath [
        libcxx
        systemd
        libpulseaudio
        stdenv.cc.cc
        alsaLib
        atk
        at-spi2-atk
        at-spi2-core
        cairo
        cups
        dbus
        expat
        fontconfig
        freetype
        gdk-pixbuf
        glib
        gtk3
        libnotify
        libX11
        libXcomposite
        libuuid
        libXcursor
        libXdamage
        libXext
        libXfixes
        libXi
        libXrandr
        libXrender
        libXtst
        nspr
        nss
        libxcb
        pango
        systemd
        libXScrnSaver
        libappindicator-gtk3
        libdbusmenu
      ];

      flags = (lib.optionals isWayland [
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
        "--enable-webrtc-pipewire-capturer"
      ]) ++ extraOptions;

      installPhase = ''
        mkdir -p $out/{bin,usr/lib/${pname},share/pixmaps}
        ln -s discord.png $out/share/pixmaps/${pname}.png
        ln -s "${desktopItem}/share/applications" $out/share/
        # HACKS FOR SYSTEM ELECTRON
        asar e resources/app.asar resources/app
        rm resources/app.asar
        sed -i "s|process.resourcesPath|'$out/usr/lib/${pname}'|" resources/app/app_bootstrap/buildInfo.js
        sed -i "s|exeDir,|'$out/share/pixmaps',|" resources/app/app_bootstrap/autoStart/linux.js
        asar p resources/app resources/app.asar --unpack-dir '**'
        rm -rf resources/app
        # Copy Relevanat data
        cp -r resources/*  $out/usr/lib/${pname}/
        # Create starter script for discord
        echo "#!${stdenv.shell}" > $out/bin/${pname}
        echo "exec ${electron}/bin/electron ${lib.concatStringsSep " " flags} $out/usr/lib/${pname}/app.asar \$@" >> $out/bin/${pname}
        chmod 755 $out/bin/${pname}
        wrapProgram $out/bin/${pname} \
            "''${gappsWrapperArgs[@]}" \
            --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}/" \
            --prefix LD_LIBRARY_PATH : ${libPath}
      '';

      desktopItem = makeDesktopItem {
        name = pname;
        exec = pname;
        icon = pname;
        inherit desktopName;
        genericName = meta.description;
        categories = "Network;InstantMessaging;";
        mimeType = "x-scheme-handler/discord";
      };

      meta = with lib; {
        description = "All-in-one cross-platform voice and text chat for gamers";
        homepage = "https://discordapp.com/";
        downloadPage = "https://discordapp.com/download";
        platforms = [ "x86_64-linux" ];
      };
    };
}