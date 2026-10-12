{
  description = "NixOS configuration for UWE-FSAI developer machines and vehicle compute";

  inputs = {
    # nixpkgs follows nix-ros-overlay's pin on purpose: ros.cachix.org builds
    # against exactly that revision, so following it is what makes ROS come
    # down as binaries instead of compiling for hours.
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/develop";
    nixpkgs.follows = "nix-ros-overlay/nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-substituters = [ "https://ros.cachix.org" ];
    extra-trusted-public-keys = [ "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=" ];
  };

  outputs = { self, nixpkgs, nix-ros-overlay, disko, ... }:
    let
      inherit (nixpkgs) lib;
      ads = import ./lib { inherit self nixpkgs nix-ros-overlay disko; };

      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      shellSystems = linuxSystems ++ [ "aarch64-darwin" ];
    in
    {
      lib = ads;

      # Every module is inert until enabled, so importing any of them on your
      # own machine changes nothing by itself. `default` brings in all of
      # them; the profiles then switch on a sensible set.
      nixosModules = ads.modules // {
        default = ads.allModules;
        developer = ./profiles/developer.nix;
        vehicle = ./profiles/vehicle.nix;
      };

      # Build any of these as-is:
      #   sudo nixos-rebuild switch --flake github:SethBennett2523/ads-nix#dev-x86
      nixosConfigurations = {
        dev-x86 = ads.mkSystem { system = "x86_64-linux"; modules = [ ./hosts/dev-x86.nix ]; };
        dev-x86-cuda = ads.mkSystem { system = "x86_64-linux"; modules = [ ./hosts/dev-x86-cuda.nix ]; };
        dev-aarch64 = ads.mkSystem { system = "aarch64-linux"; modules = [ ./hosts/dev-aarch64.nix ]; };
        incar-pc = ads.mkSystem { system = "x86_64-linux"; modules = [ ./hosts/incar-pc.nix ]; };
        car-sim = ads.mkSystem { system = "x86_64-linux"; modules = [ ./hosts/incar-pc.nix ./hosts/car-sim.nix ]; };
        installer = ads.mkSystem { system = "x86_64-linux"; modules = [ ./hosts/installer.nix ]; };
      };

      packages = lib.genAttrs linuxSystems (system:
        let
          cfgs = lib.filterAttrs (_: c: c.pkgs.stdenv.hostPlatform.system == system) self.nixosConfigurations;
          image = name: cfgs.${name}.config.system.build.diskoImages;
        in
        lib.optionalAttrs (system == "x86_64-linux") {
          # Ready-to-write drive images: `nix build .#usb-dev-x86`, then dd the
          # result onto a USB drive. Building these needs KVM.
          usb-dev-x86 = image "dev-x86";
          usb-dev-x86-cuda = image "dev-x86-cuda";
          incar-pc-image = image "incar-pc";
          # A boot stick that installs any of the above onto another drive,
          # with no KVM needed to build it.
          installer-iso = cfgs.installer.config.system.build.isoImage;
          car-sim-vm = cfgs.car-sim.config.system.build.vm;
        }
        // lib.optionalAttrs (system == "aarch64-linux") {
          usb-dev-aarch64 = image "dev-aarch64";
        });

      devShells = lib.genAttrs shellSystems (system:
        import ./shells { inherit system nixpkgs nix-ros-overlay; });

      templates = {
        member = {
          path = ./templates/member;
          description = "Your own machine, built on the UWE-FSAI configuration";
        };
        default = self.templates.member;
      };

      formatter = lib.genAttrs shellSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
