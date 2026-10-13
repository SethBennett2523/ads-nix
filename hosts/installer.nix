# A boot stick that installs any build type onto another drive:
#   sudo ads-install dev-x86 /dev/sdX
{ lib, pkgs, modulesPath, adsNix, ... }:
{
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];
  ads.base.enable = true;
  networking.hostName = "ads-installer";
  networking.wireless.enable = lib.mkForce false;
  environment.systemPackages = [ (adsNix.lib.installer pkgs) ];
  services.getty.helpLine = lib.mkForce ''
    UWE-FSAI installer. Connect to wifi with `nmtui`, then run
      sudo ads-install
    to see build types and drives.
  '';
}
