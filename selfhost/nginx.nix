{
  config,
  pkgs,
  lib,
  ...
}:

let
  domainServices = [
    "htop"
    "immich"
    "jellyfin"
    "radarr"
    "sonarr"
  ];

  cfg = config.selfhost.nginx;
in
{
  config = lib.mkIf cfg {
    age.secrets."cloudflare-token" = {
      file = ../secrets/cloudflare-token.age;
      owner = "root";
      group = "acme";
      mode = "0440";
    };

    services.nginx = {
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      appendHttpConfig = ''
        map $http_user_agent $bad_bot {
          default                   0;
          ""                        1;
          "~*zgrab"                 1;
          "~*masscan"               1;
          "~*nikto"                 1;
          "~*sqlmap"                1;
          "~*nmap"                  1;
          "~*python-requests"       1;
          "~*go-http-client"        1;
        }
      '';
      sslCiphers = "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305";
      sslProtocols = "TLSv1.2 TLSv1.3";
    };

    security.acme = {
      acceptTerms = true;
      email = "no-reply@dprive.fr";
      certs = builtins.listToAttrs (
        map (domain: {
          name = "${domain}.dprive.fr";
          value = {
            dnsProvider = "cloudflare";
            credentialFiles."CLOUDFLARE_DNS_API_TOKEN_FILE" = config.age.secrets."cloudflare-token".path;
            webroot = null;
          };
        }) domainServices
      );
    };

    users.users.nginx.extraGroups = [ "acme" ];

    security.apparmor.policies.nginx = {
      state = "enforce";
      profile = ''
        #include <tunables/global>

        profile nginx /run/current-system/sw/bin/nginx {
          #include <abstractions/base>
          #include <abstractions/nameservice>
          #include <abstractions/ssl_certs>

          # Binaire
          /run/current-system/sw/bin/nginx  r,

          # Config
          /etc/nginx/**             r,

          # Logs
          /var/log/nginx/**         rw,

          # Certs
          /var/lib/acme/**          r,

          # Tmp
          /tmp/nginx/**             rw,

          # Réseau
          network inet  stream,
          network inet6 stream,

          # Interdit
          deny /home/**             rw,
          deny /root/**             rw,
          deny /etc/shadow          r,
        }
      '';
    };
  };
}
