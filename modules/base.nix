# Everything every society machine shares: Nix settings, editors and core
# tools, networking, locale. All of it is set at default priority, so a plain
# assignment anywhere in your own config wins.
{ config, lib, pkgs, ... }:
let
  cfg = config.ads.base;

  ads-update = pkgs.writeShellScriptBin "ads-update" ''
    set -euo pipefail
    flake=${lib.escapeShellArg cfg.updateFlake}
    case "$flake" in
      /*|path:*)
        # A local flake (the member template): pull the newest society
        # configuration into its lock file first.
        dir=''${flake%%#*}; dir=''${dir#path:}
        sudo nix flake update ads-nix --flake "$dir"
        ;;
    esac
    exec sudo nixos-rebuild switch --flake "$flake" "$@"
  '';

  ads-version = pkgs.writeShellScriptBin "ads-version" ''
    echo "ads-nix revision: ${toString config.system.configurationRevision}"
    echo "NixOS:            ${config.system.nixos.label}"
    echo "Update source:    ${cfg.updateFlake}"
  '';
in
{
  options.ads.base = {
    enable = lib.mkEnableOption "the shared UWE-FSAI base configuration";

    updateFlake = lib.mkOption {
      type = lib.types.str;
      default = "github:SethBennett2523/ads-nix#${config.networking.hostName}";
      defaultText = lib.literalExpression ''"github:SethBennett2523/ads-nix#''${config.networking.hostName}"'';
      description = "Flake reference that `ads-update` rebuilds from.";
    };

    networkManager = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use NetworkManager for all networking (wifi, wired and the car's static profile).";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Extra packages on top of the core set.";
    };
  };

  config = lib.mkIf cfg.enable {
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "@wheel" ];
      extra-substituters = [ "https://ros.cachix.org" ];
      extra-trusted-public-keys = [ "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=" ];
      auto-optimise-store = lib.mkDefault true;
    };
    nix.gc = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
      options = lib.mkDefault "--delete-older-than 30d";
    };

    # NVIDIA drivers, firmware and a few vendor tools are unfree.
    nixpkgs.config.allowUnfree = lib.mkDefault true;

    environment.systemPackages = with pkgs; [
      ads-update
      ads-version
      # editors
      vim
      neovim
      nano
      emacs
      # everyday tools
      git
      curl
      wget
      htop
      tmux
      tree
      unzip
      file
      jq
      ripgrep
      pciutils
      usbutils
      btrfs-progs
    ] ++ cfg.extraPackages;

    programs.git.enable = lib.mkDefault true;

    networking.networkmanager.enable = lib.mkDefault cfg.networkManager;
    # Blocks boot for up to 90 s on a machine with no network (the car).
    systemd.services.NetworkManager-wait-online.enable = lib.mkDefault false;

    time.timeZone = lib.mkDefault "Europe/London";
    i18n.defaultLocale = lib.mkDefault "en_GB.UTF-8";
    console.keyMap = lib.mkDefault "uk";
    services.xserver.xkb.layout = lib.mkDefault "gb";

    zramSwap.enable = lib.mkDefault true;
    services.fstrim.enable = lib.mkDefault true;
    services.btrfs.autoScrub = lib.mkIf (config.fileSystems ? "/" && config.fileSystems."/".fsType == "btrfs") {
      enable = lib.mkDefault true;
      fileSystems = lib.mkDefault [ "/" ];
    };

    # The release these machines were first installed with. Do not bump it
    # when upgrading; it records on-disk state formats, not the version.
    system.stateVersion = lib.mkDefault "26.11";
  };
}
