# ads-nix

NixOS configuration for every machine UWE-FSAI runs: members' laptops (x86,
x86 with NVIDIA, Apple Silicon), the in-car PC and, later, the Jetson. One
pinned set of versions, so the code builds the same everywhere.

**New member?** Start with [docs/QUICKSTART.md](docs/QUICKSTART.md).
**Project lead?** [docs/RUNBOOK.md](docs/RUNBOOK.md) covers updates, the car
and handover.

## Three ways to use it

**1. As-is.** Each machine type is a complete system:

```bash
sudo nixos-rebuild switch --flake github:SethBennett2523/ads-nix#dev-x86
```

| Machine type | For |
|---|---|
| `dev-x86` | any x86 laptop or desktop, from a USB drive or an internal disk |
| `dev-x86-cuda` | the same, with the NVIDIA driver and CUDA |
| `dev-aarch64` | a VM on an Apple Silicon Mac (UTM), or an ARM machine |
| `incar-pc` | the car; starts the mission selector at boot with no input |
| `car-sim` | the car's system as a VM on your laptop, with a virtual CAN bus |

**2. As an input, with your own changes.** `nix flake init -t
github:SethBennett2523/ads-nix` gives you a small flake in `/etc/nixos` that
pulls this one in. Everything here is a *default*: anything you set in your
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

## Dev shells (any OS with Nix, including macOS)

```bash
nix develop github:SethBennett2523/ads-nix          # ROS 2 Jazzy, colcon, vcstool
nix develop github:SethBennett2523/ads-nix#humble   # for Quanser's QCar 2 nodes
nix develop github:SethBennett2523/ads-nix#tools    # Python, OpenCV, linters; no ROS
```

On a Mac the default shell is `tools`, because ROS through Nix is only
partly supported on macOS. `#ros` is there to try; for full ROS, run the
`dev-aarch64` VM.

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
