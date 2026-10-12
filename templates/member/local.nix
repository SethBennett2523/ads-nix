# Your machine, your choices. Anything set here beats the society defaults.
{ lib, pkgs, ... }:
{
  networking.hostName = "my-machine";

  # Tell `ads-update` where this flake lives.
  ads.base.updateFlake = "/etc/nixos#my-machine";

  # Examples:
  # ads.desktop.environment = "none";      # bring your own desktop below
  # programs.hyprland.enable = true;
  # ads.cuda.enable = true;                # NVIDIA machines
  # ads.ros.extraPackages = p: [ p.plotjuggler-ros ];
  # ads.user.name = "yourname";
  # environment.systemPackages = [ pkgs.zed-editor ];

  # Boot loader for an internal-drive install (nixos-generate-config writes
  # one into hardware-configuration.nix or configuration.nix; keep yours).
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
}
