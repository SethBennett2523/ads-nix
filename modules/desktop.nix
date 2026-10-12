# A desktop, if you want one. Plasma is the default because RViz, rqt and
# Gazebo are Qt applications and look and behave best there. Anything here
# loses to a plain assignment in your own config.
{ config, lib, pkgs, ... }:
let
  cfg = config.ads.desktop;
  # Beats the desktop modules' own mkDefault while still losing to a user's
  # plain assignment: a default, not a preset.
  mkDesktopDefault = lib.mkOverride 900;
in
{
  options.ads.desktop = {
    enable = lib.mkEnableOption "a graphical desktop";

    environment = lib.mkOption {
      type = lib.types.enum [ "plasma" "gnome" "xfce" "none" ];
      default = "plasma";
      description = "Desktop environment. `none` leaves the choice entirely to you.";
    };

    apps = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [ vscodium firefox ];
      defaultText = lib.literalExpression "[ vscodium firefox ]";
      description = "Desktop applications installed by default.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      environment.systemPackages = cfg.apps;
      services.pipewire = {
        enable = lib.mkDefault true;
        alsa.enable = lib.mkDefault true;
        pulse.enable = lib.mkDefault true;
      };
      hardware.bluetooth.enable = lib.mkDefault true;
      hardware.graphics.enable = lib.mkDefault true;
      fonts.packages = with pkgs; [ noto-fonts noto-fonts-color-emoji dejavu_fonts ];
    }

    (lib.mkIf (cfg.environment == "plasma") {
      services.desktopManager.plasma6.enable = true;
      services.displayManager.sddm.enable = mkDesktopDefault true;
      services.displayManager.sddm.wayland.enable = mkDesktopDefault true;
      services.displayManager.defaultSession = mkDesktopDefault "plasma";
    })

    (lib.mkIf (cfg.environment == "gnome") {
      services.desktopManager.gnome.enable = true;
      services.displayManager.gdm.enable = mkDesktopDefault true;
    })

    (lib.mkIf (cfg.environment == "xfce") {
      services.xserver.enable = true;
      services.xserver.desktopManager.xfce.enable = true;
      services.xserver.displayManager.lightdm.enable = mkDesktopDefault true;
      services.displayManager.defaultSession = mkDesktopDefault "xfce";
    })
  ]);
}
