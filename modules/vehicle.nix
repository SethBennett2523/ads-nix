# The car's computer. It boots with no network and nobody at the keyboard,
# so everything it needs happens unattended: the CAN bus comes up, then the
# mission selector starts and waits for the vehicle's autonomous state.
{ config, lib, pkgs, ... }:
let
  cfg = config.ads.vehicle;
  auto = cfg.autostart;

  launcher = pkgs.writeShellScript "ads-launch" ''
    set -eu
    ws=${lib.escapeShellArg auto.workspace}
    if [ ! -f "$ws/install/setup.bash" ]; then
      echo "ADS workspace is not built: $ws/install/setup.bash is missing" >&2
      exit 1
    fi
    set +u
    source "$ws/install/setup.bash"
    set -u
    exec ros2 launch ${lib.escapeShellArg auto.package} ${lib.escapeShellArg auto.launchFile} ${lib.escapeShellArgs auto.launchArgs}
  '';
in
{
  options.ads.vehicle = {
    enable = lib.mkEnableOption "the in-car computer role";

    network = {
      address = lib.mkOption {
        type = lib.types.str;
        default = "10.10.0.10";
        description = "Static address on the car's wired network. Set a travel router's LAN to 10.10.0.1/24 to match.";
      };
      prefixLength = lib.mkOption { type = lib.types.ints.between 0 32; default = 24; };
      gateway = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
    };

    autostart = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Start the mission selector at boot.";
      };
      user = lib.mkOption {
        type = lib.types.str;
        default = config.ads.user.name;
        defaultText = lib.literalExpression "config.ads.user.name";
      };
      workspace = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/ads/ads-ws";
        description = "Built colcon workspace on the car's drive.";
      };
      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/ads/data";
        description = "Working directory of the launch; ros2 bag records land here.";
      };
      package = lib.mkOption { type = lib.types.str; default = "launch_files"; };
      launchFile = lib.mkOption { type = lib.types.str; default = "ads_launch.py"; };
      launchArgs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "can_interface:=${config.ads.can.hardware.interface}" ];
        defaultText = lib.literalExpression ''[ "can_interface:=''${config.ads.can.hardware.interface}" ]'';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Matched on connection type rather than interface name, so it works
    # whatever the kernel calls the port (enp2s0, eno1, ...).
    networking.networkmanager.ensureProfiles.profiles.car-wired = {
      connection = {
        id = "car-wired";
        type = "ethernet";
        autoconnect = "true";
        autoconnect-priority = "100";
      };
      ipv4 = {
        method = "manual";
        address1 = "${cfg.network.address}/${toString cfg.network.prefixLength}"
          + lib.optionalString (cfg.network.gateway != null) ",${cfg.network.gateway}";
        never-default = lib.boolToString (cfg.network.gateway == null);
        ignore-auto-dns = "true";
      };
      ipv6.method = "disabled";
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/ads 0755 ${auto.user} users -"
      "d ${auto.dataDir} 0755 ${auto.user} users -"
    ];

    systemd.services.ads = lib.mkIf auto.enable (
      let canUnit = "can-${config.ads.can.hardware.interface}.service";
      in {
        description = "ADS mission selector";
        wantedBy = [ "multi-user.target" ];
        after = [ "local-fs.target" "systemd-tmpfiles-setup.service" ] ++ lib.optional config.ads.can.hardware.enable canUnit;
        wants = lib.optional config.ads.can.hardware.enable canUnit;
        path = [ "/run/current-system/sw" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = launcher;
          User = auto.user;
          WorkingDirectory = auto.dataDir;
          # Raw SocketCAN without running as root.
          AmbientCapabilities = [ "CAP_NET_RAW" ];
          Restart = "on-failure";
          RestartSec = 5;
          # mission_handler starts child launches with subprocess.Popen;
          # stopping the unit must stop them too.
          KillMode = "control-group";
          TimeoutStopSec = 20;
        };
      });

    # Keep logs across reboots so a failed run can be diagnosed afterwards.
    services.journald.settings.Journal = {
      Storage = lib.mkDefault "persistent";
      SystemMaxUse = lib.mkDefault "2G";
    };

    boot.loader.timeout = lib.mkDefault 1;
  };
}
