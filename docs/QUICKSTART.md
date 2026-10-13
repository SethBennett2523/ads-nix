# Getting started

Pick the route that matches your machine. All of them end with the same
tools and the same versions as everyone else.

## Windows or Linux laptop: boot from a USB drive

You'll run the society's system from an external USB drive (an SSD on USB 3
is much faster than a memory stick; 128 GB or more). Your laptop's own disk
is never touched.

**If a lead hands you a ready-made drive**, skip to *First boot*.

**Making your own drive.** You need two USB devices: a small stick for the
installer and the drive you'll keep.

1. Download `ads-installer.iso` from the repository's latest release.
2. Write it to the small stick with [balenaEtcher](https://etcher.balena.io)
   (Windows/macOS) or `dd` (Linux).
3. Boot the laptop from the stick (see *Booting from USB* below).
4. Plug in the drive you'll keep. Connect to wifi with `nmtui`.
5. Run `sudo ads-install` to see the drives, then, for example:
   ```
   sudo ads-install dev-x86 /dev/sdb
   ```
   Use `dev-x86-cuda` instead if the laptop has an NVIDIA GPU. Read the drive
   name carefully: the one you pick is erased.
6. Shut down, remove the installer stick, and boot from your drive.

### Booting from USB

- Turn **Secure Boot off** in the firmware settings. The drive won't boot
  with it on.
- Press the boot-menu key while the laptop starts (often F12, F11, F9 or
  Esc; Lenovo: F12, Dell: F12, HP: F9, ASUS: Esc or F8) and pick the USB
  drive.
- Windows' *Fast Startup* can stop the laptop seeing USB at boot; turn it
  off in Power Options if the drive doesn't appear.

### First boot

1. Log in as `uweai` with password `uwe-fsai`.
2. Run `passwd` and set your own password. The default is printed in a
   public repository.
3. Connect to wifi from the network icon.
4. Run `ads-update` whenever a lead says there's an update.

The drive grows to fill its full size on first boot.

## MacBook

Apple Silicon Macs can't boot this system from USB, so there are two
options, and most people want the first.

**Your department's shell (recommended).** Install Nix from
[nixos.org/download](https://nixos.org/download), then in a terminal, with
your department's name:

```bash
nix develop github:SethBennett2523/ads-nix#perception
```

Departments: `integration`, `perception`, `planning`, `slam`, `simulation`.
That gives you your department's Python libraries and tools, natively.
ROS is the part that isn't reliable on macOS through Nix;
`nix develop github:SethBennett2523/ads-nix#ros` is there to try.

**Full system in a VM**, for anything that needs ROS, RViz or Gazebo:

1. Install [UTM](https://mac.getutm.app) and create a Linux VM from the
   NixOS *minimal ISO, ARM64* ([nixos.org/download](https://nixos.org/download)),
   with at least 8 GB RAM and a 64 GB disk.
2. Boot it and run:
   ```bash
   sudo nix --extra-experimental-features 'nix-command flakes' \
     run github:nix-community/disko/latest#disko-install -- \
     --flake github:SethBennett2523/ads-nix#vm-aarch64 --disk main /dev/vda
   ```
3. Remove the ISO from the VM, reboot, and follow *First boot* above.

## Any other Linux, without installing NixOS

Install Nix from [nixos.org/download](https://nixos.org/download) and use
your department's shell, as above. On Linux it includes the full ROS 2 setup.

## A virtual machine instead

Use `vm-x86` (or `vm-aarch64` on Apple Silicon) with the installer steps
above, inside UTM, virt-manager or GNOME Boxes. To try the system without
installing anything, on a machine that already has Nix:

```bash
nixos-rebuild build-vm --flake github:SethBennett2523/ads-nix#vm-x86 && ./result/bin/run-vm-x86-vm
nixos-rebuild build-vm --flake github:SethBennett2523/ads-nix#adsdv-sim && ./result/bin/run-adsdv-sim-vm   # the car's build
```

## You already run NixOS

Keep your setup and pull in what you want:

```bash
cd /etc/nixos
sudo nix flake init -t github:SethBennett2523/ads-nix
```

Then edit `local.nix` (anything you set wins over the society defaults) and
keep your own `hardware-configuration.nix`. To take only parts, drop the
`developer` profile and import modules one by one; see the README.
