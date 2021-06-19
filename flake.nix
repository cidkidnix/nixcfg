{
    inputs = {
        nixpkgs = { url = "github:NixOS/nixpkgs/nixos-unstable"; };
        nixpkgs2009 = { url = "github:NixOS/nixpkgs/nixos-20.09"; };
        home-manager = { url = "github:nix-community/home-manager"; };
        nur = { url = "github:nix-community/NUR"; };
        flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";
        wine-wayland = { url = "git+https://gitlab.collabora.com/alf/wine?ref=wayland"; flake = false; };
        wine-lol = { url = "github:lutris/wine/lutris-lol-5.5"; flake = false; };
        mozilla = { url = "github:mozilla/nixpkgs-mozilla"; flake = false; };
        sops-nix = { url = "github:Mic92/sops-nix"; };
        agenix = { url = "github:ryantm/agenix"; };
        musnix = { url = "github:cidkidnix/musnix/b45d670b2c79c071e4b8affb52d42f9604bd3130"; };


        home-manager.inputs.nixpkgs.follows = "nixpkgs";
    };

    outputs = inputs:
      let
        remoteNixpkgsPatches = [ 
        ];
        localNixpkgsPatches = [ ];
        originPkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
        nixpkgs = originPkgs.applyPatches {
          name = "nixpkgs-patched";
          src = inputs.nixpkgs;
          patches = map originPkgs.fetchpatch remoteNixpkgsPatches ++ localNixpkgsPatches;
          postPatch = ''
            patch=$(printf '%s\n' ${builtins.concatStringsSep " " (map (p: p.sha256) remoteNixpkgsPatches ++ localNixpkgsPatches)} |sort | sha256sum | cut -c -7)
            echo "+patch-$patch" >.version-suffix
          '';
        };

        lib = originPkgs.lib;

        machines = builtins.mapAttrs (machineName: machineConfig:
          let cfg = import machineConfig { inherit inputs; }; in
          import (nixpkgs + "/nixos/lib/eval-config.nix") (cfg // {
            extraArgs = {
              inherit machineName inputs;
              machines = inputs.self.nixosConfigurations;
            } // (cfg.extraArgs or {});
            modules = cfg.modules ++ [({pkgs, ...}: {
              system.nixos.revision = lib.mkIf (inputs.self ? rev) inputs.self.rev;
              nixpkgs.config = {};
              nixpkgs.overlays = [ overrides desktopapps inputs.nur.overlay ];
              # Let 'nixos-version --json' know about the Git revision of this flake.
              system.configurationRevision = lib.mkIf (inputs.self ? rev) inputs.self.rev;
      })];
    }));
        overrides = self: super: rec {
          xwayland = super.xwayland.overrideAttrs ({ patches ? [ ], ... }: {
            preConfigure = ''
              patch -p1 < ${./machines/cfg/patches/xwayland.patch}
            '';
          });

          libinput-patched = super.libinput.overrideAttrs (old: {
            patches = (old.patches or []) ++ [ ./machines/cfg/patches/libinput.patch ];
          });

          wine-cemu = super.wineWowPackages.unstable.overrideAttrs (old: {
            patches = (old.patches or []) ++ [ ./machines/cfg/patches/wine/childwindow.patch ];
          });

          wine-wayland-osu = (super.wineStable.overrideDerivation (
            { buildInputs ? [ ]
            , configureFlags ? [ ]
            , makeFlags ? [ ]
            , patches ? [ ]
            , ... 
            }: {
              src = inputs.wine-wayland;
              buildInputs = buildInputs ++ (with super.pkgsi686Linux; [
                wayland libxkbcommon wayland.dev
              ]);
              configureFlags = configureFlags ++ [ "--with-wayland" ];
              XKBCOMMON_CFLAGS = "-I${super.pkgsi686Linux.libxkbcommon.dev}/include";
              XKBCOMMON_LIBS = "-L${super.pkgsi686Linux.libxkbcommon.out}/lib -lxkbcommon";
              patches = patches ++ [ ./machines/cfg/patches/wine/winepulse-v6.10-wasapifriendly.patch ];
            }
          )).override {
            mingwSupport = true;
            vulkanSupport = true;
          };

          wine-osu = super.wineUnstable.overrideAttrs (old: {
            src = super.fetchurl {
              url = "https://dl.winehq.org/wine/source/6.x/wine-6.7.tar.xz";
              sha256 = "sha256-wwUUt3YdRhFRSuAhyx41QSjXfv9UooPxQB7nAid7vqQ=";
            };
            patches = old.patches ++ [ ./machines/cfg/patches/wine/winepulse-revert.patch ];
          });

          winetricks = super.winetricks.override {
            wine = wine-osu;
          };

          wlroots-patched = super.wlroots.overrideAttrs (old: {
            buildInputs = with super; [
              libGL wayland wayland-protocols libinput-patched libxkbcommon pixman
              xorg.xcbutilwm xorg.libX11 libcap xorg.xcbutilimage xorg.xcbutilerrors mesa
              libpng ffmpeg libuuid xorg.xcbutilrenderutil xwayland
            ];
          });

          sway = super.sway.overrideAttrs (old: {
            buildInputs = with super; [
              wayland libxkbcommon pcre json_c dbus libevdev
              pango cairo libinput-patched libcap pam gdk-pixbuf librsvg
              wlroots-patched wayland-protocols libdrm
            ];
          });

          materia-theme = super.materia-theme.overrideAttrs (old: {
            src = super.fetchFromGitHub {
              owner = "nana-4";
              repo = old.pname;
              rev = "v20210322";
              sha256 = "sha256-dHcwPTZFWO42wu1LbtGCMm2w/YHbjSUJnRKcaFllUbs=";
            };
          });

          beatmap-importer = super.writeShellScriptBin "beatmap-import" ''
            #!/usr/bin/env bash
            cp ~/Downloads/*.osz ~/.osu/Songs && rm ~/Downloads/*.osz
          '';

          #freecad = super.freecad.override {
          #  spaceNavSupport = false;
          #};

          minecraft-bedrock-appimage = super.appimageTools.wrapType2 {
            name = "minecraft-bedrock";
            src = super.fetchurl {
              url = "https://github.com/ChristopherHX/linux-packaging-scripts/releases/download/v0.2.1-661/Minecraft_Bedrock_Launcher-x86_64-0.0.661.AppImage";
              sha256 = "";
            };
            extraPkgs = pkgs: with super; [ libpulseaudio alsaLib alsaUtils pkgsi686Linux.zlib ];
          };

          spotifyd = super.spotifyd.override {
            withMpris = true;
            withPulseAudio = true;
          };

          vscodium-wayland = super.vscodium.overrideAttrs (old: {
            buildInputs = old.buildInputs ++ [
              super.makeWrapper
            ];
            postInstall = ''
                wrapProgram $out/bin/codium \
                  --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland" 
            '';
          });

          element-wayland = super.element-desktop.overrideAttrs (old: {
            buildInputs = old.buildInputs ++ [
              super.makeWrapper
            ];
            postInstall = ''
              wrapProgram $out/bin/element-desktop \
                --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
            '';
          });

          alvr = super.callPackage ./machines/cfg/packages/alvr {};

          ### Nopaystation
          pkg2zip = super.callPackage ./machines/cfg/packages/pkg2zip {};
          nps = super.callPackage ./machines/cfg/packages/nps {};

          ### Openauto
          aasdk = super.callPackage ./machines/cfg/packages/aasdk {};
          openauto = super.libsForQt5.callPackage ./machines/cfg/packages/openauto {};

          ### Cockpit
          cockpit = super.callPackage ./machines/cfg/packages/cockpit {};

          ### mpv-notify-send
          mpv-notify-send = super.callPackage ./machines/cfg/packages/mpv-notify-send {};

          ### Optabletdriver
          #opentabletdriver-updated = super.callPackage ./machines/cfg/packages/opentabletdriver {};

          ### Discord 0.0.15 update
          #discord = super.discord.overrideAttrs (_: {
          #  src = super.fetchurl {
          #    url = "https://dl.discordapp.net/apps/linux/0.0.15/discord-0.0.15.tar.gz";
          #    sha256 = "sha256-re3pVOnGltluJUdZtTlSeiSrHULw1UjFxDCdGj/Dwl4=";
          # };
          #});
          
          linux-cidkid = super.linuxPackagesFor (super.linux_latest.override {
            ignoreConfigErrors = true;
          });

          obs-wlrobs = (super.obs-wlrobs.overrideAttrs (old: {
            src = super.fetchhg {
              url = old.src.url;
              rev = "4184a4a8ea7dc054c993efa16007f3a75b2c6f51";
              sha256 = "sha256-rKmhsP/Fxdz5JBIosxCYyc+YwzaAeBNE04Hb0X6O3ZA=";
            };
          })).override {
            dmabufSupport = true;
          };
          
          # Pin gnome3
          #gnome = inputs.nixpkgs2009.legacyPackages.x86_64-linux.gnome3;

          /*
            subset = (super.subset // {
              packagename = super.subset.packagename.overrideAttrs (old: {});
            });
          */
        };

        desktopapps = import ./machines/cfg/overlays/desktopapps.nix;
        discord-wayland = import ./machines/cfg/overlays/discord-wayland.nix;

      in rec {
          nixosConfigurations = machines {
            jupiter = machines/nixos-desktop;
          };
      };
}
