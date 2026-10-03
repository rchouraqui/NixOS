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
    hardware.nvidia = {
      open = false;
      modesetting.enable = true;
      powerManagement = {
        enable = false;
        finegrained = false;
      };
      nvidiaSettings = true;
    };
    services = {
      xserver.videoDrivers = [ "nvidia" ];
    };
    boot.kernelParams = [ "nvidia-drm.modeset=1" ];
  };
}
