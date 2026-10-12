# A boot stick that installs any machine type onto another drive:
#   sudo ads-install dev-x86 /dev/sdX
{ lib, pkgs, modulesPath, ... }:
let
  ads-install = pkgs.writeShellApplication {
    name = "ads-install";
    runtimeInputs = with pkgs; [ util-linux nix git ];
    text = ''
      flake=''${ADS_FLAKE:-github:SethBennett2523/ads-nix}
      if [ $# -ne 2 ]; then
        echo "usage: sudo ads-install <machine-type> <disk>"
        echo "machine types: dev-x86 dev-x86-cuda dev-aarch64 incar-pc"
        echo
        lsblk -d -o NAME,SIZE,MODEL,TRAN
        exit 1
      fi
      host=$1; disk=$2
      echo "This ERASES $disk and installs $host from $flake."
      lsblk "$disk"
      read -r -p "Type 'yes' to continue: " ok
      [ "$ok" = yes ] || exit 1
      exec nix --extra-experimental-features 'nix-command flakes' \
        run github:nix-community/disko/latest#disko-install -- \
        --flake "$flake#$host" --disk main "$disk"
    '';
  };
in
{
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];
  ads.base.enable = true;
  networking.hostName = "ads-installer";
  networking.wireless.enable = lib.mkForce false;
  environment.systemPackages = [ ads-install ];
  services.getty.helpLine = lib.mkForce ''
    UWE-FSAI installer. Connect to wifi with `nmtui`, then run
      sudo ads-install
    to see machine types and drives.
  '';
}
