# Your changes to this machine. Anything set here beats the society's
# defaults, and society updates (`ads-update`) never overwrite this file.
#
# Edit it with:   sudo nano /etc/nixos/local.nix
# Then apply:     ads-apply
#
# To use an example, remove the # at the start of its line.
{ lib, pkgs, ... }:
{
  # Extra programs:
  # environment.systemPackages = with pkgs; [ spotify discord ];

  # A different desktop: "plasma" (default), "gnome", "xfce" or "none".
  # ads.desktop.environment = "gnome";

  # Extra ROS packages:
  # ads.ros.extraPackages = p: [ p.plotjuggler-ros ];

  # Your own login name instead of uweai (your files stay with the old user):
  # ads.user.name = "yourname";
}
