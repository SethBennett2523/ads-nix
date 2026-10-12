# The car's configuration as a VM on your laptop, with a virtual CAN bus in
# place of the real one:  nixos-rebuild build-vm --flake .#car-sim
{ lib, ... }:
{
  networking.hostName = lib.mkForce "car-sim";
  ads.cuda.enable = lib.mkForce false;
  ads.can = {
    virtual.enable = lib.mkForce true;
    hardware.enable = lib.mkForce false;
  };
  ads.vehicle.autostart.launchArgs = lib.mkForce [ "can_interface:=vcan0" ];
  virtualisation.vmVariant.virtualisation = {
    memorySize = 4096;
    cores = 2;
  };
}
