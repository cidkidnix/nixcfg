{ config, pkgs, lib, ... }:
{
    systemd.nspawn."Arch" = {
      enable = true;
      execConfig = {
        Timezone = "Bind";
        Hostname = "Arch";
        SystemCallFilter = "modify_ldt";
        Capability = [
          "NET_CAP_ADMIN"
        ];
      };
      filesConfig = {
        Bind = [ "/home/cidkid/.container-home-arch:/home/cidkid" "/run/user/1000/wayland-1" "/tmp/.X11-unix/X0" "/run/user/1000/pulse/native" "/dev/dri" "/dev/shm" "/tank" "/tank/containers/config/10-host.network:/etc/systemd/network/10-host.network" ];
        BindReadOnly = [ "/home/cidkid:/mnt/cidkid" ];
        Volatile = false;
      };
      networkConfig = {
        Private = false;
        VirtualEthernet = false;
      };
    };

    systemd.services."systemd-nspawn@".serviceConfig = {
      ### Vulkan support
      DeviceAllow = [
        "char-drm rw"
        "/dev/dri/renderD128"
      ];
    };

    systemd.tmpfiles.rules = [
        "L /var/lib/machines/Fedora - - - - /tank/containers/Fedora"
        "L /var/lib/machines/Arch - - - - /tank/containers/Arch"
    ];

    security.polkit.extraConfig = ''
      polkit.addRule(
        function(action, subject) {
          if (action.id.startsWith("org.freedesktop.machine1.") && subject.user == "cidkid") {
            return polkit.Result.YES;
          }
        }
      );

      polkit.addRule(
        function(action, subject) {
          if ((action.id.startsWith("org.freedesktop.machine1.") || (action.id == "org.freedesktop.systemd1.manage-units" && action.lookup("unit").startsWith("systemd-nspawn@"))) && subject.user == "cidkid") {
            return polkit.Result.YES;
          }
        }
      );
    '';
}