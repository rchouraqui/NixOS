{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  htop = import ./htop.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
  nginx = import ./nginx.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
  jellyfin = import ./jellyfin.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
  immich = import ./immich.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
  nextcloud = import ./nextcloud.nix {
    inherit
      inputs
      config
      pkgs
      lib
      ;
  };
  cfg = config.selfhost;

in
{
  imports = [
    htop
    nginx
    jellyfin
    immich
    nextcloud
  ];

  options.selfhost = {
    htop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the htop";
    };
    nginx = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the nginx";
    };
    jellyfin = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the jellyfin";
    };
    immich = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the immich";
    };
    nextcloud = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the nextcloud";
    };
  };
}
