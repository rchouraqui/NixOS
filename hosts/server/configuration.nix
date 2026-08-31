{
  config,
  inputs,
  lib,
  nixName,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/games/default.nix
    ../../modules/graphical/default.nix
    ../../modules/hardware/default.nix
    ../../modules/users/default.nix
    ../../modules/applications/default.nix
    ../../selfhost/default.nix
  ];

  networking = {
    hostName = "server";
    firewall.enable = true;
    interfaces.enp2s0.ipv4.addresses = [
      {
        address = "10.0.10.4";
        prefixLength = 24;
      }
    ];
    defaultGateway = {
      address = "10.0.10.1";
      interface = "enp2s0";
    };
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
      "8.8.4.4"
    ];
  };

  config-hw = {
    nix-settings = true;
    keyboard = true;
    bluetooth = false;
    printer = false;
  };

  config-user = {
    raph = true;
  };

  graphical = {
    enable = false;
    greetd = false;
  };

  applications = {
    docker = true;
    virtualbox = false;
    wireguard = false;
    man = true;
    ssh = true;
  };

  games = {
    steam = false;
  };

  selfhost = {
    htop = true;
    nginx = true;
    jellyfin = true;
    immich = true;
    nextcloud = true;
  };

  system.stateVersion = "25.11";
}
