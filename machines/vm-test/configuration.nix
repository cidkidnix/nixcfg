{ config, pkgs, lib, ... }:

{
  users.users.vm-test = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = "test123";
  };

  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;
  services.xserver.libinput.enable = true;

  services.pipewire = {
	  enable = true;
	  pulse.enable = true;
	  alsa.enable = true;
    alsa.support32Bit = true;
	  jack.enable = true;
  };

  sound.enable = true;
  hardware.pulseaudio.enable = lib.mkForce false;
}