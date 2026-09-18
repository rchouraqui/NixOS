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
  ];

  networking = {
    hostName = "framework";
    networkmanager = {
      enable = true;
      wifi = {
        powersave = false;
        macAddress = "preserve";
      };
    };
  };

  config-hw = {
    nix-settings = true;
    keyboard = true;
    bluetooth = true;
    printer = true;
  };

  config-user = {
    raph = true;
  };

  graphical = {
    enable = true;
    greetd = true;
  };

  applications = {
    docker = true;
    virtualbox = true;
    wireguard = true;
    man = true;
    ssh = false;
    flatpak = true;
  };

  games = {
    steam = false;
  };

  system.stateVersion = "25.11";
}
