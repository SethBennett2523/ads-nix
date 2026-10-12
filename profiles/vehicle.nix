# Quickstart for the car: headless ROS, the real CAN bus, unattended start.
{ lib, ... }:
{
  ads.base.enable = lib.mkDefault true;
  ads.user.enable = lib.mkDefault true;
  ads.remoteAdmin.enable = lib.mkDefault true;
  ads.vehicle.enable = lib.mkDefault true;

  ads.ros = {
    enable = lib.mkDefault true;
    desktop = lib.mkDefault false;
    gazebo = lib.mkDefault false;
    localhostOnly = lib.mkDefault false;
  };

  ads.can = {
    enable = lib.mkDefault true;
    virtual.enable = lib.mkDefault false;
    hardware.enable = lib.mkDefault true;
  };

  ads.desktop.enable = lib.mkDefault false;
}
