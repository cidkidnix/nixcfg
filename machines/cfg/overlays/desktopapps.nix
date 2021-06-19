self: super: rec {
    osu = super.writeTextDir "share/applications/osu.desktop" ''
        [Desktop Entry]
        Name=Osu!
        Type=Application
        Exec=${osu-sh}/bin/osu-sh
    '';

    osu-sh = super.writeShellScriptBin "osu-sh" ''
        export STAGING_AUDIO_DURATION=20000
        export STAGING_AUDIO_PERIOD=10000
        export WINEPREFIX="/home/cidkid/.wine-osu"
        export vblank_mode=0
        cd /home/cidkid/.osu
        ${super.wine-osu}/bin/wine osu\!.exe &
        sleep 2 
        ${super.wine-osu}/bin/wine ${../wine/winediscordipcbridge.exe}
    '';
    
    
    /*osu-sh-wayland = super.writeShellScriptBin "osu-sh" ''
        export STAGING_AUDIO_DURATION=30000
        export STAGING_AUDIO_PERIOD=10000
        export WINEPREFIX="/home/cidkid/.wine-osu"
        export vblank_mode=0
        export DISPLAY=
        export WAYLAND_DISPLAY=wayland-1
        cd /home/cidkid/.osu
        ${super.wine-wayland-osu}/bin/wine osu\!.exe &
        sleep 2
        ${super.wine-wayland-osu}/bin/wine ${../wine/winediscordipcbridge.exe}
    '';
    */

    cura-desktop = super.writeTextDir "share/applications/cura.desktop" ''
        [Desktop Entry]
        Name=Cura
        Type=Application
        Exec=env QT_QPA_PLATFORM=xcb ${super.cura}/bin/cura
        Icon=${super.cura}/share/icons/hicolor/128x128/apps/cura-icon.png
    '';

    pulseeffects-desktop = super.writeTextDir "share/applications/pulseeffects.desktop" ''
        [Desktop Entry]
        Name=PulseEffects
        Type=Application
        Exec=${super.pulseeffects-pw}/bin/pulseeffects
    '';

    scrcpy-desktop = super.writeTextDir "share/applications/scrcpy.desktop" ''
        [Desktop Entry]
        Name=Scrcpy
        Type=Application
        Exec=${super.scrcpy}/bin/scrcpy -S --render-driver=opengl
    '';

    rpcs3-desktop = super.writeTextDir "share/applications/rpcs3.desktop" ''
        [Desktop Entry]
        Name=RPCS3
        Type=Application
        Icon=rpcs3
        Exec=env QT_QPA_PLATFORM=xcb ${super.rpcs3}/bin/rpcs3
        Terminal=false
    '';

    helvum-desktop = super.writeTextDir "share/applications/helvum.desktop" ''
        [Desktop Entry]
        Name=Helvum
        Type=Application
        Exec=${super.helvum}/bin/helvum
        Terminal=false
    '';

    lutris-arch = super.writeTextDir "share/applications/lutris.desktop" ''
        [Desktop Entry]
        Name=Lutris
        Type=Application
        Exec=${super.systemd}/bin/machinectl shell cidkid@Arch /usr/bin/lutris
    '';
}