# Replace this file with your own:
#   sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
{
  fileSystems."/" = { device = "/dev/disk/by-label/nixos"; fsType = "ext4"; };
  fileSystems."/boot" = { device = "/dev/disk/by-label/boot"; fsType = "vfat"; };
}
