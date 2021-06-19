{ config, pkgs, inputs, lib, overlay-2009, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../cfg/home-manager/cidkid/cidkid.nix
      ./base.nix
      ./desktop.nix
      ./nix.nix
    ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = (with pkgs; [
    wget vim unzip git mkpasswd pciutils usbutils p7zip
    linuxPackages.cpupower dmidecode 
  ]) ++ (with inputs; [
    agenix.defaultPackage.x86_64-linux 
  ]);
  nixpkgs.config.allowUnfree = true;

  programs.steam.enable = true;
  programs.adb.enable = true;
  #virtualisation.anbox.enable = true;
  #virtualisation.anbox.image = pkgs.anbox-postmarketos-image;

  # No touch
  system.stateVersion = "21.05"; # Did you read the comment?

}