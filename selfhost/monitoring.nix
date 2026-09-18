{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.selfhost.monitoring;
in
{
  config = lib.mkIf cfg {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    services = {

      nginx = {
        enable = true;
        virtualHosts."monitoring.dprive.fr" = {
          useACMEHost = "monitoring.dprive.fr";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:3000";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}
