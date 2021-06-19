{ config, pkgs, lib, home-manager, ... }:
{
    services.xserver.desktopManager.gnome.enable = true;
    services.xserver.displayManager.gdm.enable = true;

    environment.systemPackages = with pkgs; [
        gnome.gnome-tweaks gnomeExtensions.gsconnect
        gnomeExtensions.appindicator
    ];

    services.gnome = {
        gnome-keyring.enable = true;
        chrome-gnome-shell.enable = false;
        gnome-online-miners.enable = true;
        gnome-initial-setup.enable = false;
        gnome-settings-daemon.enable = true;
        gnome-remote-desktop.enable = false;
        gnome-online-accounts.enable = true;
        at-spi2-core.enable = true;
        tracker.enable = true;
        core-os-services.enable = true;
        tracker-miners.enable = true;
        glib-networking.enable = true;
    };

    programs = {
        gnome-disks.enable = true;
        gnome-terminal.enable = true;
        gnome-documents.enable = false;
    };

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

    home-manager.users.cidkid = {
      gtk = {
          enable = true;
          theme = {
              name = "Materia-dark-compact";
              package = pkgs.materia-theme;
          };
          iconTheme = {
              name = "Papirus-Dark";
              package = pkgs.papirus-icon-theme;
          };
      };

      programs.gnome-terminal.enable  = true;
	  programs.gnome-terminal.profile = {
		"f2afd3c7-cb35-4d08-b6c2-523b444be64d" = {
			visibleName   = "pastel";
			showScrollbar = false;
			default = true;

			font	= "Source Code Pro 10";
			colors  = {
				backgroundColor = "#161616";
				foregroundColor = "#E5E5E5";
				palette = [
					"#272224" "#FF473D" "#3DCCB2" "#FF9600"
					"#3B7ECB" "#F74C6D" "#00B5FC" "#3E3E3E"

					"#52494C" "#FF6961" "#85E6D4" "#FFB347"
					"#779ECB" "#F7A8B8" "#55CDFC" "#EEEEEC"
				];
			};
		};
    };

    };
}