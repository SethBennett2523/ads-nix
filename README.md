# ads-nix

NixOS configuration for every machine UWE-FSAI runs: members' laptops (x86,
x86 with NVIDIA, Apple Silicon), the in-car PC and, later, the Jetson. One
pinned set of versions, so the code builds the same everywhere.

**New member?** Start with [docs/setup](docs/setup/README.md): guides for a Mac, a PC or laptop, and existing NixOS users.
**Project lead?** [docs/RUNBOOK.md](docs/RUNBOOK.md) covers updates, the car
and handover.

## Three ways to use it

**1. As-is.** Each build type is a complete system:

```bash
sudo nixos-rebuild switch --flake github:SethBennett2523/ads-nix#dev-x86
```

or onto a fresh drive, from any NixOS live USB:

```bash
sudo nix --extra-experimental-features 'nix-command flakes' run --accept-flake-config \
  github:SethBennett2523/ads-nix#ads-install -- dev-x86 /dev/sdX
```

| Build type | For | Login |
|---|---|---|
| `dev-x86` | any x86 laptop or desktop, from a USB drive or an internal disk | `uweai` |
| `dev-x86-cuda` | the same, with the NVIDIA driver and CUDA | `uweai` |
| `vm-x86` | a VM on an x86 Windows, Linux or Intel Mac machine | `uweai` |
| `vm-aarch64` | a VM on an Apple Silicon Mac (UTM) | `uweai` |
| `adsdv` | the car (Autonomous Driving System, Designated Vehicle); starts the mission selector at boot with no input | leads only, over SSH |
| `adsdv-sim` | the car's build as a VM on your laptop, with a virtual CAN bus | `uweai` |

On the car the stack runs as `adsdv`, a service account nobody logs in as.

**2. As an input, with your own changes.** `nix flake init -t
github:SethBennett2523/ads-nix` gives you a small flake that pulls this one
in ([guide](docs/setup/nixos.md)). Everything here is a *default*: anything you set in your
`local.nix` wins, and your config never leaves your machine.

**3. Just the parts you want.** Each module is inert until enabled, so an
existing config can take only, say, ROS:

```nix
imports = [ ads-nix.nixosModules.ros ];
ads.ros.enable = true;
```

Modules: `base`, `users`, `ros`, `desktop`, `cuda`, `can`, `remote-admin`,
`portable`, `vehicle`, plus the `developer` and `vehicle` profiles that switch
on a sensible set.

## Department shells (any OS with Nix, including macOS)

For working on your own machine without installing NixOS:

```bash
nix develop github:SethBennett2523/ads-nix#perception
```

| Shell | Linux | macOS |
|---|---|---|
| `integration` | ROS 2 Jazzy, xacro, RViz, rqt, python-can, cantools, can-utils | python-can, can-utils |
| `perception` | ROS 2 Jazzy, cv_bridge, PyTorch, Ultralytics, OpenCV | PyTorch, Ultralytics, OpenCV |
| `planning` | ROS 2 Jazzy, RViz, ackermann_msgs, simple-pid | NumPy, SciPy, simple-pid |
| `slam` | ROS 2 Jazzy, GTSAM (C++), RViz, Eigen | NumPy, SciPy, Eigen |
| `simulation` | ROS 2 Jazzy, Gazebo (ros_gz), xacro, RViz, rqt | NumPy, pandas |
| `default` | ROS 2 Jazzy, colcon, vcstool | general tools, no ROS |
| `humble` | ROS 2 Humble, for Quanser's QCar 2 nodes | |
| `tools` | Python, linters; no ROS | the same |

All of them include NumPy, SciPy, Matplotlib, pytest, ruff and the ament
linters' Python side, so the code style checks match CI. ROS through Nix is
only partly supported on macOS, so Mac shells leave it out; `#ros` is there
to try, and the `vm-aarch64` build gives full ROS on a Mac.

GTSAM's Python bindings, which `graphslam_node` imports, aren't packaged yet.

## Checking a change

```bash
./scripts/check.sh
```

evaluates every machine, image and shell. CI runs the same on every push.

## Layout

```
flake.nix           inputs (nixpkgs follows nix-ros-overlay, for the ROS binary cache)
lib/                mkSystem, the shared btrfs disk layout
modules/            the ads.* options
profiles/           developer and vehicle quickstarts
hosts/              the machine types above, and the installer stick
shells/             dev shells
templates/member/   the flake a member keeps in /etc/nixos
scripts/check.sh    evaluate everything
```
