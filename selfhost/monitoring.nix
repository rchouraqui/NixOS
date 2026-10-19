{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.selfhost.monitoring;
  monitoredUrls = [
    "https://sso.dprive.fr"
    "https://jellyfin.dprive.fr"
    "https://sonarr.dprive.fr"
    "https://radarr.dprive.fr"
    "https://vault.dprive.fr"
    "https://nextcloud.dprive.fr"
    "https://grafana.dprive.fr"
  ];
in
{
  config = lib.mkIf cfg {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    age.secrets = {
      "grafana-oidc-secret" = {
        file = ../../secrets/grafana-oidc-secret.age;
        owner = "kanidm";
        group = "grafana";
        mode = "0440";
      };

      "grafana-secret-key" = {
        file = ../../secrets/grafana-secret-key.age;
        owner = "grafana";
        group = "grafana";
        mode = "0400";
      };
    };

    services = {
      kanidm = {
        provision = {
          systems.oauth2.grafana = {
            present = true;
            displayName = "Grafana";
            originUrl = "https://monitor.dprive.fr";
            originLanding = "https://monitor.dprive.fr/login/generic_oauth";
            basicSecretFile = config.age.secrets.grafana-oidc-secret.path;
            public = false;
            enableLocalhostRedirects = false;
            allowInsecureClientDisablePkce = false;
            preferShortUsername = true;
            scopeMaps = {
              grafana_superadmins = [
                "openid"
                "profile"
                "groups"
              ];
              grafana_admins = [
                "openid"
                "profile"
                "groups"
              ];
              grafana_editors = [
                "openid"
                "profile"
                "groups"
              ];
              grafana_users = [
                "openid"
                "profile"
                "groups"
              ];
            };
            claimMaps = {
              groups = {
                joinType = "array";
                valuesByGroup = {
                  grafana_superadmins = [
                    "grafana_superadmins"
                  ];
                  grafana_admins = [
                    "grafana_admins"
                  ];
                  grafana_editors = [
                    "grafana_editors"
                  ];
                  grafana_users = [
                    "grafana_users"
                  ];
                };
              };
            };
          };
        };
      };

      nginx = {
        enable = true;
        virtualHosts."grafana.dprive.fr" = {
          useACMEHost = "grafana.dprive.fr";
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
