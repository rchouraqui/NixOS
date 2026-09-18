{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.selfhost.vault;
  data_dir = "/mnt/nas";
in
{
  config = lib.mkIf cfg {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    age.secrets = {
      "vault-oidc-secret" = {
        file = ../secrets/vault-oidc-secret.age;
        owner = "kanidm";
        group = "kanidm";
        mode = "0400";
      };

      "vault-secret-env" = {
        file = ../secrets/vault-secret-env.age;
        owner = "vaultwarden";
        group = "vaultwarden";
        mode = "0400";
      };
    };

    fileSystems."/mnt/nas/vault" = {
      device = "10.0.10.3:/mnt/HDD/vault";
      fsType = "nfs";
      options = [
        "nfsvers=4.2"
        "_netdev"
        "x-systemd.automount"
      ];
    };

    users = {
      groups.datausers = { };
      users.vaultwarden.extraGroups = [
        "datausers"
      ];
    };

    services = {
      vaultwarden = {
        enable = true;
        environmentFile = config.age.secrets.vault-secret-env.path;
        config = {
          DOMAIN = "https://vault.dprive.fr";
          SIGNUPS_ALLOWED = false;
          ROCKET_PORT = 8222;
          SSO_ENABLED = true;
          SSO_CLIENT_ID = "vault";
          SSO_AUTHORITY = "https://sso.dprive.fr/oauth2/openid/vault";
          SSO_SIGNUPS_MATCH_EMAIL = true;
          SSO_PKCE = true;
          SSO_SCOPES = "openid profile email";
          SSO_ONLY = true;
          DATA_FOLDER = "${data_dir}/vault";
        };
      };

      kanidm.provision.systems.oauth2.vault = {
        present = true;
        displayName = "Vault";
        originUrl = "https://vault.dprive.fr";
        originLanding = "https://vault.dprive.fr/identity/connect/oidc-signin";
        basicSecretFile = config.age.secrets.vault-oidc-secret.path;
        public = false;
        enableLocalhostRedirects = false;
        allowInsecureClientDisablePkce = false;
        preferShortUsername = true;
        scopeMaps = {
          vault_admins = [
            "openid"
            "profile"
            "email"
          ];
          vault_users = [
            "openid"
            "profile"
            "email"
          ];
        };
      };

      nginx = {
        enable = true;
        virtualHosts."vault.dprive.fr" = {
          useACMEHost = "vault.dprive.fr";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:8222";
            proxyWebsockets = true;
          };
        };
      };
    };
    security.apparmor.policies.vaultwarden = {
      state = "enforce";
      profile = ''
        #include <tunables/global>
        profile vaultwarden /run/current-system/sw/bin/vaultwarden {
          #include <abstractions/base>
          #include <abstractions/nameservice>
          #include <abstractions/ssl_certs>
          /run/current-system/sw/bin/vaultwarden  r,
          /mnt/nas/vault/**  rw,
          /etc/vaultwarden/**      r,
          /var/log/vaultwarden/**  rw,
          network inet  stream,
          network inet6 stream,
          deny /home/**            rw,
          deny /root/**            rw,
          deny /etc/shadow         r,
          deny /etc/passwd         rw,
        }
      '';
    };
    systemd.tmpfiles.rules = [
      "d /mnt/nas/vault 0750 vaultwarden vaultwarden -"
    ];

    systemd.services.vaultwarden.serviceConfig.ReadWritePaths = [
      "/mnt/nas/vault"
    ];
  };
}
