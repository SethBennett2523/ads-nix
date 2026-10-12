# A member's x86 laptop or desktop, booted from a USB drive or installed on
# an internal one. Hardware-independent: the same drive boots anywhere.
{ lib, ... }:
{
  imports = [ ../profiles/developer.nix ];
  networking.hostName = lib.mkDefault "dev-x86";
  ads.portable.enable = lib.mkDefault true;
}
