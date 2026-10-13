# Installs a build type onto a drive:  ads-install dev-x86 /dev/sdb
#
# Runs from any NixOS live ISO (`nix run github:SethBennett2523/ads-nix#ads-install`)
# or from the ads installer stick. It partitions with disko, then runs
# nixos-install, which downloads the system straight onto the target drive.
# (disko-install would download it into the live system's memory first,
# which a full desktop and ROS do not fit in on most laptops.)
{ lib, writeShellApplication, util-linux, coreutils, nixos-install-tools, disko, flake }:
writeShellApplication {
  name = "ads-install";
  runtimeInputs = [ util-linux coreutils nixos-install-tools disko ];
  text = ''
    types="dev-x86 dev-x86-cuda vm-x86 vm-aarch64 adsdv"
    usage() {
      echo "usage: sudo ads-install <build-type> <disk>"
      echo
      echo "build types: $types"
      echo
      echo "drives on this machine:"
      lsblk -d -o NAME,SIZE,MODEL,TRAN | sed 's/^/  /'
      exit 1
    }
    [ $# -eq 2 ] || usage
    host=$1; disk=$2
    case " $types " in *" $host "*) ;; *) echo "unknown build type: $host"; usage ;; esac
    [ -b "$disk" ] || { echo "not a disk: $disk"; usage; }
    [ "$(id -u)" -eq 0 ] || { echo "run with sudo"; exit 1; }

    echo
    lsblk -o NAME,SIZE,MODEL,TRAN,MOUNTPOINTS "$disk"
    echo
    echo "This ERASES everything on $disk and installs $host."
    read -r -p "Type the disk name ($disk) to continue: " ok
    [ "$ok" = "$disk" ] || { echo "Cancelled."; exit 1; }

    echo "Partitioning $disk..."
    disko --mode destroy,format,mount --yes-wipe-all-disks \
      --argstr device "$disk" ${flake}/lib/disko-btrfs.nix

    echo "Installing $host. The first install downloads several GB."
    nixos-install --root /mnt --no-root-password --no-channel-copy \
      --flake "${flake}#$host" \
      --option extra-substituters https://ros.cachix.org \
      --option extra-trusted-public-keys ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=

    umount -R /mnt
    echo
    echo "Done. Shut down, remove the installer, and boot from $disk."
    echo "Log in as uweai with password uwe-fsai, then run passwd."
  '';
  meta.description = "Install a UWE-FSAI build type onto a drive";
}
