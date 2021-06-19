{ config, pkgs, lib, ... }:
let
    cfg = programs.cockpit;
in
{
    options = {
        enable = mkEnableOption "Cockpit server manager";
    };

    config = mkIf cfg.enable {
        environment.etc.""
    }
}