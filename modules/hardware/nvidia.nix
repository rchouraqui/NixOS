{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.config-hw.nvidia;
in
{
  config = lib.mkIf cfg {
    hardware = {
      nvidia = {
        open = true;
        modesetting.enable = true;
        powerManagement = {
          enable = false;
          finegrained = false;
        };
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.latest;
      };
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
    services = {
      xserver.videoDrivers = [ "nvidia" ];
    };
    boot.kernelParams = [ "nvidia-drm.modeset=1" ];
  };
}
