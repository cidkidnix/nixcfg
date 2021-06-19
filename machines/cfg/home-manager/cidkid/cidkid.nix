{ config, pkgs, inputs, home-manager, lib, agenix, ... }:

{
  imports = [
    ../../mixins/sway/sway.nix
    ../../mixins/firefox/firefox.nix
    ../../mixins/age/age.nix
  ];

  users.users.cidkid = {
    isNormalUser = true;
    home = "/home/cidkid";
    extraGroups = [ "wheel" "networkmanager" "audio" "video" "users" "adbusers" "libvirtd" ]; # Enable ‘sudo’ for the user.
    hashedPassword = builtins.readFile ./passwd.cfg;
  };
  users.mutableUsers = false;
  users.defaultUserShell = pkgs.zsh;
  environment.pathsToLink = [ "/share/zsh" ];

  systemd.user.services.xrandrd = {
    after = [ "default.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.bash}/bin/bash ${../../scripts/xrandr.sh}";
    };
    path = [ pkgs.xorg.xrandr ];
    environment = {
      DISPLAY = ":0";
    };
  };
  
  home-manager.users.cidkid = {
    home.packages = with pkgs; [
      spotify pavucontrol  openssl betterdiscord-installer lutris-arch
      pulseeffects-pw winetricks cura-desktop osu scc multimc
      element-wayland virt-manager patchage neofetch imv beatmap-importer 
      scrcpy-desktop bitwarden discord dolphinEmuMaster rpcs3-desktop
      pkg2zip nps fusee-interfacee-tk freecad evince
    ];

    home.file = {
      ".local/bin/discordipc.sh" = {
        source = ../../wine/winediscordipcbridge.sh;
        executable = true;
      };

      ### MultiMC Mods for Vanilla ###
      ".local/share/multimc/resourcepacks/faithful.zip".source = builtins.fetchurl {
        url = "https://github.com/FaithfulTeam/Faithful/raw/releases/1.17.zip";
        sha256 = "sha256:0llnswikr93491sdxpklryvajbw4l36w3c2wf670vkmlax9bpmjj";
      };
    };

    xdg = {
      enable = true;
      userDirs.enable = true;
      userDirs.createDirectories = true;
    };

    programs.git = {
        enable = true;
        userName = "cidkidnix";
        userEmail = "cidkidnix@protonmail.com";
    };

    programs.obs-studio = {
      enable = true;
      plugins = with pkgs; [
        obs-wlrobs
      ];
    };

    programs.mpv = {
      enable = true;
      scripts = with pkgs; [
        mpvScripts.mpris
        mpv-notify-send
      ];
    };

    programs.zsh = {
        enable = true;
        enableAutosuggestions = true;
        enableCompletion = true;
        shellAliases = {
          "ls" = "${pkgs.exa}/bin/exa -TL1";
        };
        oh-my-zsh = {
          enable = true;
          theme = "agnoster";
        };
    };

    programs.vscode = {
      enable = true;
      package = pkgs.vscodium-wayland;
      extensions = [ pkgs.vscode-extensions.jnoortheen.nix-ide ];
      userSettings = {
        "window.titleBarStyle" = "native";
        "workbench.activityBar.visible" = false;
        "window.menuBarVisibility" = "hidden";
        "workbench.statusBar.visible" = false;
        "workbench.colorTheme" = "Visual Studio Dark";
        "workbench.colorCustomizations" = {
          "sideBar.background" = "#161616";
          "editor.background" = "#161616";
          "editorGroupHeader.tabsBackground" = "#161616";
        };
      };
    };
  };
}
