{ config, pkgs, lib, ... }:
{
  config = lib.mkIf config.virtualisation.anbox.enable {
    systemd.user.services.anbox-session-manager = {
      after = [ "default.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.anbox}/bin/anbox session-manager";
        Restart = "on-failure";
        StartLimitBurst = 5;
      };
      environment = {
        DISPLAY = ":0";
        SDL_VIDEODRIVER = "x11";
      };
    };
  };
}