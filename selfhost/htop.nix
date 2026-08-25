{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.selfhost.htop;
in
{
  config = lib.mkIf cfg {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    services = {
      glances.enable = true;

      nginx = {
        enable = true;
        virtualHosts."htop.dprive.fr" = {
          useACMEHost = "htop.dprive.fr";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:61208";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}
