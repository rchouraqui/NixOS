{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.applications.flatpak;
in
{
  config = lib.mkIf cfg {
    services.flatpak = {
      enable = true;
    };
  };
}
