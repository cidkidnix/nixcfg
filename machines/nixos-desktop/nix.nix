{ config, pkgs, lib, ... }:
{
  nix = {
    autoOptimiseStore = true;
    maxJobs = 4;
    buildCores = 3;
  };
}
