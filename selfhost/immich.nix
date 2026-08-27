{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.selfhost.immich;
  data_dir = "/mnt/nas/immich";
in
{
  config = lib.mkIf cfg {
    fileSystems."/mnt/nas/immich" = {
      device = "10.0.10.3:/mnt/HDD/immich-photos";
      fsType = "nfs";
      options = [
        "nfsvers=4.2"
        "_netdev"
      ];
    };
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    users = {
      groups.datausers = { };
      users.immich.extraGroups = [
        "video"
        "render"
        "datausers"
      ];
    };
    services = {
      immich = {
        enable = true;
        port = 2283;
        openFirewall = true;
        host = "127.0.0.1";
        mediaLocation = "${data_dir}";
        machine-learning.enable = false;
        redis.enable = true;
        settings = {
          server = {
            externalDomain = "https://immich.dprive.fr";
            loginPageMessage = "Welcome to the cloud";
            publicUsers = false;
          };
        };
      };

      nginx = {
        enable = true;
        virtualHosts."immich.dprive.fr" = {
          useACMEHost = "immich.dprive.fr";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:2283";
            proxyWebsockets = true;
          };
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d /mnt/nas/immich 2770 root datausers -"
      "d /mnt/nas/immich0750 immich immich -"
    ];
  };
}
