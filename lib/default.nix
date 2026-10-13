{ self, nixpkgs, nix-ros-overlay, disko }:
let
  inherit (nixpkgs) lib;

  modules = {
    base = ../modules/base.nix;
    users = ../modules/users.nix;
    ros = import ../modules/ros.nix { inherit nix-ros-overlay; };
    desktop = ../modules/desktop.nix;
    cuda = ../modules/cuda.nix;
    can = ../modules/can.nix;
    remote-admin = ../modules/remote-admin.nix;
    portable = ../modules/portable.nix;
    vehicle = ../modules/vehicle.nix;
  };
in
{
  inherit modules;

  allModules = { imports = builtins.attrValues modules; };

  # The ads-install script, for a given package set.
  installer = pkgs: pkgs.callPackage ../pkgs/ads-install.nix {
    disko = disko.packages.${pkgs.stdenv.hostPlatform.system}.disko;
    flake = self;
  };

  # The shared btrfs disk layout, for hosts that want it.
  diskoBtrfs = import ./disko-btrfs.nix;

  # Builds a machine from this flake's modules plus your own. Members'
  # flakes can call this instead of nixpkgs.lib.nixosSystem.
  mkSystem = { system, modules ? [ ], specialArgs ? { } }:
    lib.nixosSystem {
      inherit system;
      specialArgs = { adsNix = self; } // specialArgs;
      modules = [
        self.nixosModules.default
        disko.nixosModules.disko
        {
          nixpkgs.hostPlatform = lib.mkDefault system;
          system.configurationRevision = lib.mkDefault (self.rev or self.dirtyRev or null);
        }
      ] ++ modules;
    };
}
