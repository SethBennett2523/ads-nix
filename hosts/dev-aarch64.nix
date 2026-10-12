# ARM64: a UTM or Parallels VM on an Apple Silicon Mac, or an ARM board.
# XFCE by default because it is light inside a VM.
{ lib, ... }:
{
  imports = [ ../profiles/developer.nix ];
  networking.hostName = lib.mkDefault "dev-aarch64";
  ads.portable.enable = lib.mkDefault true;
  ads.desktop.environment = lib.mkDefault "xfce";
  services.qemuGuest.enable = lib.mkDefault true;
  services.spice-vdagentd.enable = lib.mkDefault true;
}
