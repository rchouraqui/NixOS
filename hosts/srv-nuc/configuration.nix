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
    hostName = "srv-nuc";
    interfaces.enp1s0.ipv4.addresses = [
      {
        address = "10.0.10.4";
        prefixLength = 24;
      }
    ];
    vlans = {
      vlan20 = { id=20; interface="enp1s0"; }; #Prod Vlan
    };
    interfaces.vlan20.ipv4.addresses = [
      {
      address = "10.0.20.4";
      prefixLength = 24;
      }
    ];
  };

  config-hw = {
    nix-settings = true;
    network = true;
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
    flashcards = true;
  };

  system.stateVersion = "25.11";
}
