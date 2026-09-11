{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.selfhost.sso;
  kanidm-admin = config.age.secrets."kanidm-admin".path;
  kanidm-idmAdmin = config.age.secrets."kanidm-idmAdmin".path;
in
{
  config = lib.mkIf cfg {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    age.secrets = {
      "kanidm-admin" = {
        file = ../secrets/kandim-admin.age;
        owner = "kanidm";
        group = "kanidm";
        mode = "0400";
      };

      "kanidm-idmAdmin" = {
        file = ../secrets/kandim-idmAdmin.age;
        owner = "kanidm";
        group = "kanidm";
        mode = "0400";
      };
    };

    users = {
      groups.kanidm = { };
      users.kanidm = {
        isSystemUser = true;
        group = "kanidm";
        extraGroups = [ "acme" ];
      };
    };

    services = {
      kanidm = {
        package = pkgs.kanidmWithSecretProvisioning_1_10;
        server = {
          enable = true;
          settings = {
            domain = "dprive.fr";
            origin = "https://sso.dprive.fr";
            bindaddress = "127.0.0.1:9000";
            tls_chain = "/var/lib/acme/sso.dprive.fr/fullchain.pem";
            tls_key = "/var/lib/acme/sso.dprive.fr/key.pem";
          };
        };
        client = {
          enable = true;
          settings.uri = config.services.kanidm.server.settings.origin;
        };

        provision = {
          enable = true;
          autoRemove = false;
          adminPasswordFile = kanidm-admin;
          idmAdminPasswordFile = kanidm-idmAdmin;
          persons = {
            raph = {
              displayName = "Raphael";
              legalName = "Raphael Chouraqui";
              mailAddresses = [
                "raphaelchouraqui92@gmail.com"
              ];
              groups = [
                "nextcloud_admins"
              ];
            };
          };
          groups = {
            nextcloud_admins = {
              present = true;
            };
            nextcloud_users = {
              present = true;
            };
          };
        };
      };

      nginx = {
        enable = true;
        virtualHosts."sso.dprive.fr" = {
          useACMEHost = "sso.dprive.fr";
          forceSSL = true;
          locations."/" = {
            proxyPass = "https://127.0.0.1:9000";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_ssl_verify off;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto https;
            '';
          };
        };
      };
    };
  };
}
