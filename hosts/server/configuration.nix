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
    interfaces.enp2s0.ipv4.addresses = [
      {
        address = "10.0.10.4";
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
    jellyfin = true;
    flashcards = true;
  };

  system.stateVersion = "25.11";
}
