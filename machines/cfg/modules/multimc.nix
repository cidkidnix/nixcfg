{ config, pkgs, lib, ... }:
let
    cfg = programs.multimc;
in
{
    options = {
        enable = mkEnableOption "MultiMC management";

        mods = types.listOf types.path {
            
        };
        
        textures = types.listOf types.path {

        };

    };
}