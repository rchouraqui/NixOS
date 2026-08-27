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
  flashcards = import ./flashcards.nix {
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
    flashcards
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
    flashcards = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the flashcards";
    };
  };
}
