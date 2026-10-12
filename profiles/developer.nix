# Quickstart for a member's machine: everything switched on at default
# priority. Turn any piece off, or change it, with a plain assignment.
{ lib, ... }:
{
  ads.base.enable = lib.mkDefault true;
  ads.user.enable = lib.mkDefault true;
  ads.ros.enable = lib.mkDefault true;
  ads.desktop.enable = lib.mkDefault true;
  ads.can.enable = lib.mkDefault true;
  ads.remoteAdmin.enable = lib.mkDefault true;
}
