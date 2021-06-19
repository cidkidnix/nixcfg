{ config, pkgs, lib, ... }:
{
    environment.etc."greetd/config.toml".text = ''
        [terminal]
        vt = 1

        [default_session]
        command = "${pkgs.sway}/bin/sway -c /etc/greetd/sway-config"
        user = "${config.users.users.greeter.name}"
    '';

    environment.etc."greetd/environments".text = ''
        sway
        bash
        zsh
    '';

    environment.etc."greetd/sway-config".text = ''
        exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
        exec "GTK_THEME=Plata-Noir-Compact ${pkgs.greetd.gtkgreet}/bin/gtkgreet -l; swaymsg exit"
        bindsym Mod4+shift+e exec ${pkgs.wlogout}/bin/wlogout

        output HDMI-A-1 resolution 1600x900 position 0,380
        output DP-2     resolution 1920x1080@144Hz position 1600,380 max_render_time 1 adaptive_sync on
        output HDMI-A-2	resolution 1920x1080@75Hz position 3520,0 transform 90

        input "9610:8226:Glorious_Model_O_Wireless" {
          pointer_accel -0.7
          accel_profile flat
        }
    '';

    security.pam.services.greetd = {
        allowNullPassword = true;
        startSession = true;
    };

    systemd.services."autovt@tty1".enable = lib.mkForce false;
    systemd.services."getty@tty1".enable = lib.mkForce false;
    systemd.services.display-manager = lib.mkForce {
        enable = true;

        unitConfig = lib.mkForce {
            Wants = [
                "systemd-user-sessions.service"
            ];
            After = [
                "systemd-user-sessions.service"
                "plymouth-quit-wait.service"
                "getty@tty1.service"
            ];
            Conflicts = [
                "getty@tty1.service"
            ];
        };

        serviceConfig = {
            ExecStart = lib.mkForce "${pkgs.greetd.greetd}/bin/greetd";
            IgnoreSIGPIPE = "no";
            SendSIGHUP = "yes";
            TimeoutStopSec = "30s";
            KeyringMode = "shared";

            StartLimitBurst = lib.mkForce "5";
        };

        startLimitIntervalSec = 30;
        restartTriggers = lib.mkForce [];
        restartIfChanged = false;
        stopIfChanged = false;
        aliases = [ "greetd.service" ];
        wantedBy = [ "graphical.target" ];
    };

    users.users.greeter.isSystemUser = true;
    users.users.greeter.packages = [ pkgs.plata-theme ];
}