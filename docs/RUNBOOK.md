# Runbook for project leads

## Updating everyone

1. Change the configuration on a branch and run `./scripts/check.sh`.
2. Merge to `main` once CI is green.
3. Tell members to run `ads-update`. Machines built straight from this repo
   rebuild from `main`; members on the template pull the new revision into
   their own lock file first.

Rolling back is the boot menu: every rebuild keeps the previous systems
selectable, so a bad update can always be undone by rebooting into the last
good one.

### Moving to newer packages

```bash
nix flake update
./scripts/check.sh
```

`nixpkgs` follows `nix-ros-overlay`'s own pin on purpose. ros.cachix.org
builds against exactly that revision, so following it is what makes ROS
download as binaries rather than compile. Don't point `nixpkgs` elsewhere
without accepting long builds.

## Granting SSH access

SSH accepts keys only, never passwords. Add the lead's public key and merge:

```nix
# hosts/<type>.nix, or a member's local.nix
ads.remoteAdmin.adminKeys = [ "ssh-ed25519 AAAA... name@laptop" ];
```

## Making drives in bulk

On a Linux machine with KVM (any NixOS laptop):

```bash
nix build .#usb-dev-x86 --accept-flake-config      # or usb-dev-x86-cuda
sudo dd if=result/main.raw of=/dev/sdX bs=4M status=progress conv=fsync
```

The image is 32 GB (48 GB with CUDA) and grows to fill the drive on first
boot. Images are hardware-independent, so one build serves every drive.

The installer stick, for members making their own drive, needs no KVM:

```bash
nix build .#installer-iso --accept-flake-config
```

Attach `result/iso/*.iso` to a GitHub release as `ads-installer.iso`.

## The car (ADSDV)

The in-car PC boots its SATA SSD with no network and no keyboard, so
everything is unattended:

1. GRUB waits 1 second, then boots.
2. NetworkManager puts the wired port on `10.10.0.10/24`. Set a travel
   router's LAN to `10.10.0.1/24` and SSH in from the paddock.
3. `can0` comes up at 500 kbit/s when the adapter appears.
4. `adsdv.service`, running as the `adsdv` service account, sources `/var/lib/ads/ads-ws/install/setup.bash` and runs
   `ros2 launch launch_files ads_launch.py can_interface:=can0`. Bags land in
   `/var/lib/ads/data`. It restarts on failure; logs with
   `journalctl -u adsdv -b`.

Write the SSD with `nix build .#adsdv-image` and `dd`, as above, or with
`ads-install adsdv /dev/sdX` from a NixOS live USB. Either way, connect the
car's SATA SSD through a **USB-to-SATA adapter**: `ads-install` only writes
to USB drives, so it can never touch the bench machine's own disk. Leads log in
as `uweai` over SSH and are in the `adsdv` group, so they can deploy to
`/var/lib/ads` without becoming the service account.

**Gap to close:** the ADS workspace isn't packaged in Nix yet, so after
writing the image, the built workspace has to be copied to
`/var/lib/ads/ads-ws`, built inside `nix develop` with this flake's pinned
ROS. Packaging the runtime packages with `buildRosPackage` will make the
image complete on its own.

Test the car's system without the car:

```bash
nixos-rebuild build-vm --flake .#adsdv-sim && ./result/bin/run-adsdv-sim-vm
```

**Competition:** Formula Student restricts wireless links to the vehicle.
Use the router in the paddock only, and disconnect it for dynamic runs. The
remote emergency stop is a separate, specified system.

## Moving this repo to the society

The flake references `github:SethBennett2523/ads-nix` in a few places. After
forking, find and repoint them:

```bash
grep -rn "SethBennett2523/ads-nix" --exclude=flake.lock .
```

A **public** repository also makes CI free without limits, and lets members
fetch the flake without a GitHub login. It holds no secrets by design.

## Handover checklist

1. Add the incoming lead's SSH key to `ads.remoteAdmin.adminKeys`.
2. Give them admin on the GitHub repository.
3. Remove your own key once they've confirmed access.
4. Walk them through this file.

## Known gaps

- No Jetson Orin host yet (needs jetpack-nixos and a JetPack 6 release).
- ZED and Quanser SDKs aren't packaged; they need their vendor installers.
- `lyrical` dev shell: not yet verified to evaluate.
- Nothing has been built on real hardware yet, only evaluated.
