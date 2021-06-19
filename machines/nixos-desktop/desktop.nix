{ config, pkgs, lib, ... }:
{

  imports = [ 
    ./pipewire.nix
  ];

  security.rtkit.enable = true;
   
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.libinput.enable = true;

  boot.plymouth.enable = true;

  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;

  # ETC config for desktop stuff, Pipewire replaced by my pipewire.nix module
  environment.systemPackages = with pkgs; [
    pulseaudio
  ];
  environment.etc."pipewire/media-session.d/default-profile".source = ../cfg/pipewire/default-profile;
  environment.sessionVariables = {
    "MOZ_ENABLE_WAYLAND" = "1";
    "CLUTTER_DEFAULT_FPS" = "144";
  };


  fonts.fonts = with pkgs; [
    powerline-fonts
    source-code-pro
    cantarell_fonts
    font-awesome
  ];

  sound.enable = true;
  hardware.pulseaudio.enable = lib.mkForce false;
}
