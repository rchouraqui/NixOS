{
  config,
  pkgs,
  lib,
  ...
}:

let
  docker = import ./docker.nix {
    inherit config pkgs lib;
  };
  man = import ./man.nix {
    inherit config pkgs lib;
  };
  virtualbox = import ./virtualbox.nix {
    inherit config pkgs lib;
  };
  ssh = import ./ssh.nix {
    inherit config pkgs lib;
  };
  wireguard = import ./wireguard.nix {
    inherit config pkgs lib;
  };
  flatpak = import ./flatpak.nix {
    inherit config pkgs lib;
  };
in
{
  imports = [
    docker
    man
    virtualbox
    ssh
    wireguard
    flatpak
  ];

  options.applications = {
    docker = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable the docker configuration";
    };
    man = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable the man configuration";
    };
    virtualbox = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable the virtualbox configuration";
    };
    ssh = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable the ssh configuration";
    };
    wireguard = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable the wireguard configuration";
    };
    flatpak = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "enable the flatpak configuration";
    };
  };
}
