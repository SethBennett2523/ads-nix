# Shared by the VM build types: guest tools for QEMU-based hypervisors (UTM,
# virt-manager, GNOME Boxes), and a light desktop.
{ lib, ... }:
{
  imports = [ ../profiles/developer.nix ];
  ads.portable.enable = lib.mkDefault true;
  ads.portable.disk.imageSize = lib.mkDefault "48G";
  ads.desktop.environment = lib.mkDefault "xfce";
  services.qemuGuest.enable = lib.mkDefault true;
  services.spice-vdagentd.enable = lib.mkDefault true;
}
