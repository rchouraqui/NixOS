{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let

  nix-settings = import ./nix-settings.nix {
    inherit config pkgs lib;
  };
  keyboard = import ./keyboard.nix {
    inherit config pkgs lib;
  };
  network = import ./network.nix {
    inherit config pkgs lib;
  };
  bluetooth = import ./bluetooth.nix {
    inherit config pkgs lib;
  };
  printer = import ./printer.nix {
    inherit config pkgs lib;
  };

in
{
  imports = [
    nix-settings
    keyboard
    network
    bluetooth
    printer
    inputs.agenix.nixosModules.default
  ];

  options.config-hw = {
    network = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Network configuration";
    };
    nix-settings = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Nix-Settings configuration";
    };
    keyboard = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Keyboard configuration";
    };
    bluetooth = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Bluetooth configuration";
    };
    printer = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the printer configuration";
    };
  };

  config = {
    programs.zsh.enable = true;
    users.defaultUserShell = pkgs.zsh;

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    time.timeZone = "Europe/Paris";
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "fr_FR.UTF-8";
        LC_IDENTIFICATION = "fr_FR.UTF-8";
        LC_MEASUREMENT = "fr_FR.UTF-8";
        LC_MONETARY = "fr_FR.UTF-8";
        LC_NAME = "fr_FR.UTF-8";
        LC_NUMERIC = "fr_FR.UTF-8";
        LC_PAPER = "fr_FR.UTF-8";
        LC_TELEPHONE = "fr_FR.UTF-8";
        LC_TIME = "fr_FR.UTF-8";
      };
    };

    hardware = {
      enableRedistributableFirmware = true;
      enableAllFirmware = true;
    };

    environment.systemPackages = with pkgs; [
      vim
      tree
      ripgrep
      wget
      wireguard-tools
      git
      home-manager
      zsh
      vulkan-tools
      openssl
      age
    ]
    ++ [
      inputs.agenix.packages.${pkgs.system}.agenix
    ];
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };
}
