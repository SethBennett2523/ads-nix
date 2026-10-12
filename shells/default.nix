# Development shells: `nix develop github:SethBennett2523/ads-nix#<name>`.
#
# On Linux they carry the same pinned ROS as every machine. On macOS, ROS
# through Nix is only partly supported upstream, so the default Mac shell is
# everything except ROS (Python, vision and training tools, linters), and
# `ros` is offered as an experiment.
{ system, nixpkgs, nix-ros-overlay }:
let
  pkgs = import nixpkgs {
    inherit system;
    overlays = [ nix-ros-overlay.overlays.default ];
    config.allowUnfree = true;
  };
  inherit (pkgs) lib;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  python = pkgs.python3.withPackages (ps: with ps; [
    numpy
    scipy
    matplotlib
    pandas
    opencv4
    pyyaml
    ipython
    pytest
  ]);

  tools = with pkgs; [ git cmake gnumake pkg-config ruff clang-tools nixfmt ];

  rosShell = distro: pkgs.mkShell {
    name = "ads-${distro}";
    packages = tools ++ [
      pkgs.colcon
      pkgs.rosPackages.${distro}.vcstool
      (pkgs.rosPackages.${distro}.buildEnv {
        paths = with pkgs.rosPackages.${distro}; [
          ros-base
          ament-cmake
          ament-cmake-python
          ament-cmake-core
          python-cmake-module
          rosidl-default-generators
          launch-ros
        ];
      })
    ];
    shellHook = ''
      export ROS_AUTOMATIC_DISCOVERY_RANGE=''${ROS_AUTOMATIC_DISCOVERY_RANGE:-LOCALHOST}
      echo "ROS 2 ${distro} from ads-nix. Build with: colcon build --symlink-install"
    '';
  };

  toolsShell = pkgs.mkShell {
    name = "ads-tools";
    packages = tools ++ [ python ];
    shellHook = ''
      echo "ads-nix tools shell (no ROS). For ROS on a Mac, use the dev-aarch64 VM."
    '';
  };
in
if isDarwin then {
  default = toolsShell;
  tools = toolsShell;
  ros = rosShell "jazzy";
} else {
  default = rosShell "jazzy";
  humble = rosShell "humble";
  lyrical = rosShell "lyrical";
  tools = toolsShell;
}
