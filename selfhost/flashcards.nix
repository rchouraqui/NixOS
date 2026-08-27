{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.selfhost.flashcards;
  data_dir = "/var/lib/flashcards";
in
{
  config = lib.mkIf cfg {

    services = {
      nginx = {
        enable = true;
        virtualHosts."flashcards.dprive.fr" = {
          useACMEHost = "flashcards.dprive.fr";
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
