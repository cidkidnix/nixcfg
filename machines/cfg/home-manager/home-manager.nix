{ config, pkgs, home-manager, lib, ... }:
{
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
}