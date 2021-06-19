{ config, pkgs, lib, home-manager, ... }:
{
  imports = [
      ../../display-managers/greetd.nix
      ../../wlogout/wlogout.nix
  ];

  networking.firewall.allowedTCPPortRanges = [
    {
      from = 1714;
      to = 1764;
    }
  ];
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 1714;
      to = 1764;
    }
  ];

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraSessionCommands = ''
      export XDG_CURRENT_DESKTOP=sway
      export QT_QPA_PLATFORM=wayland-egl
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
    '';
    extraPackages = with pkgs; [
      swaylock-effects
      mako
      playerctl
      foot
      grim
      slurp
      waybar
      wofi
      wlogout
      oguri
      swappy
    ];
  };

  environment.etc."sway/config".source = ../../sway/config;
  environment.etc."xdg/waybar/style.css".source = ../../waybar/style.css;
  environment.etc."xdg/waybar/config".source = ../../waybar/config;

#  xdg.portal = {
#    enable = true;
#    gtkUsePortal = true;
#    extraPortals = with pkgs; [
#      xdg-desktop-portal-wlr
#      xdg-desktop-portal-gtk
#    ];
#  };
  
  systemd.user.services.mako = {
    partOf = [ "default.target" ];
    wantedBy = [ "default.target" ];
    after = [ "default.target" ];
    serviceConfig = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecStart = "${pkgs.mako}/bin/mako";
      ExecReload = "${pkgs.mako}/bin/makoctl reload";
    };
    environment = {
      WAYLAND_DISPLAY = "wayland-1";
    };
  };

  systemd.user.services.foot-server = {
    partOf = [ "default.target" ];
    wantedBy = [ "default.target" ];
    after = [ "default.target" ];
    startLimitIntervalSec = 30;
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.bash}/bin/bash ${../../scripts/foot.sh}";
      Restart = "on-failure";
      StartLimitBurst = 5; 
    };
    environment = {
      WAYLAND_DISPLAY = "wayland-1";
      GTK_THEME = "${config.home-manager.users.cidkid.gtk.theme.name}";
      DISPLAY = ":0";
    };
    path = [ "/run/wrappers" ] ++ config.home-manager.users.cidkid.home.packages ++ config.environment.systemPackages;
  };

  systemd.user.services.oguri = {
    partOf = [ "default.target" ];
    wantedBy = [ "default.target" ];
    after = [ "default.target" ];
    startLimitIntervalSec = 30;
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.oguri}/bin/oguri";
      Restart = "on-failure";
      StartLimitBurst = 5;
    };
    environment = {
      WAYLAND_DISPLAY = "wayland-1";
    };
  };

  systemd.user.services.udiskie = {
    partOf = [ "default.target" ];
    wantedBy = [ "default.target" ];
    after = [ "default.target" ];
    serviceConfig = {
      Type="simple";
      ExecStart = "${pkgs.udiskie}/bin/udiskie -a -n -s";
    };
    environment = {
      WAYLAND_DISPLAY = "wayland-1";
    };
  };
  
  home-manager.users.cidkid = {
    programs.mako = {
      enable = true;
      backgroundColor = "#161616";
      borderColor = "#161616";
      borderRadius = 5;
      borderSize = 1;
      defaultTimeout = 3000;
    };
    
    home.file = {
      ### Wallpaper Config ###
      ".config/oguri/config".text = ''
        [output *]
        image=${../../sway/wallpaper.gif}
        filter=nearest
        scaling-mode=fill
        anchor=center
      '';

      ### Screenshot tool config ###
      ".config/swappy/config".text = ''
        [Default]
        save_dir=$HOME/Pictures
        save_filename_format=screenshot-%Y%m%d-%H%M%S.png
        show_panel=false
        line_size=5
        text_size=20
        text_font=sans-serif
      '';

      ### Terminal Config ###
      ".config/foot/foot.ini".text = ''
        font=Source Code Pro:size=10
        font-bold=Source Code Pro:size=10
        font-italic=Source Code Pro:size=10

        [scrollback]
        lines=100000

        [cursor]
        style=block

        [mouse]
        hide-when-typing=yes

        [colors]
        foreground=E5E5E5
        background=161616

        regular0=272224
        regular1=FF473D
        regular2=3DCCB2
        regular3=FF9600
        regular4=3B7ECB
        regular5=F74C6D
        regular6=00B5FC
        regular7=3E3E3E
        bright0=52494C
        bright1=FF6961
        bright2=85E6D4
        bright3=FFB347
        bright4=779ECB
        bright5=F7A8B8
        bright6=55CDFC
        bright7=EEEEEC
      '';

      ### Wofi Styling ###
      ".config/wofi/style.css".source = ../../sway/wofi/style.css;
    };

    gtk = {
      enable = true;
      theme = {
        name = "Plata-Noir-Compact";
        package = pkgs.plata-theme;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
    };
  };
}
