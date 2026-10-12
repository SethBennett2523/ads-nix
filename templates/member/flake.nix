{
  description = "My UWE-FSAI machine";

  # This file lives on YOUR machine (/etc/nixos), not in the society
  # repository, so nothing of yours is ever tracked or pushed there.
  #
  # Update to the newest society configuration with `ads-update`, or:
  #   nix flake update ads-nix && sudo nixos-rebuild switch --flake /etc/nixos#my-machine

  inputs = {
    ads-nix.url = "github:SethBennett2523/ads-nix";
    # Use the exact nixpkgs the society builds against, so ROS comes from
    # the binary cache. Drop this to bring your own nixpkgs.
    nixpkgs.follows = "ads-nix/nixpkgs";
  };

  outputs = { ads-nix, ... }: {
    nixosConfigurations.my-machine = ads-nix.lib.mkSystem {
      system = "x86_64-linux";
      modules = [
        # Pick ONE starting point. The profile switches on the full set; or
        # delete it and enable only the parts you want, e.g.
        #   ads.ros.enable = true;
        ads-nix.nixosModules.developer
        ./hardware-configuration.nix
        ./local.nix
      ];
    };
  };
}
