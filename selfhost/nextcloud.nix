{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.selfhost.nextcloud;
  data_dir = "/mnt/nas/nextcloud";
  nextcloud-admin-pass = config.age.secrets."nextcloud-admin-pass".path;
  nextcloud-database = config.age.secrets."nextcloud-database".path;
in
{
  config = lib.mkIf cfg {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    fileSystems."/mnt/nas/nextcloud" = {
      device = "10.0.10.3:/mnt/HDD/nextcloud";
      fsType = "nfs";
      options = [
        "nfsvers=4.2"
        "_netdev"
        "x-systemd.automount"
      ];
    };

    age.secrets."nextcloud-admin-pass" = {
      file = ../secrets/nextcloud-admin-pass.age;
      owner = "nextcloud";
      group = "nextcloud";
      mode = "0400";
    };
    age.secrets."nextcloud-database" = {
      file = ../secrets/nextcloud-database.age;
      owner = "nextcloud";
      group = "nextcloud";
      mode = "0400";
    };

    environment.systemPackages = with pkgs; [
      php
    ];
    users = {
      groups.datausers = { };
      users.nextcloud.extraGroups = [
        "datausers"
      ];
    };

    services = {
      postgresql = {
        enable = true;
        ensureDatabases = [
          "nextcloud"
        ];
        ensureUsers = [
          {
            name = "nextcloud";
            ensureDBOwnership = true;
          }
        ];
      };
      postgresqlBackup = {
        enable = true;
        location = "/data/backup/nextclouddb";
        databases = [
          "nextcloud"
        ];
        startAt = "*-*-* 23:15:00";
      };
      redis.servers.nextcloud = {
        enable = true;
        user = "nextcloud";
        group = "nextcloud";
        unixSocket = "/run/redis-nextcloud/redis.sock";
        unixSocketPerm = 770;
      };
      nextcloud = {
        enable = true;
        https = true;
        package = pkgs.nextcloud34;
        hostName = "nextcloud.dprive.fr";
        datadir = data_dir;
        config = {
          adminpassFile = nextcloud-admin-pass;
          adminuser = "raph";
          dbtype = "pgsql";
          dbname = "nextcloud";
          dbhost = "localhost";
          dbuser = "nextcloud";
          dbpassFile = nextcloud-database;
        };
        extraApps = {
          inherit (pkgs.nextcloud34Packages.apps)
            calendar
            contacts
            tasks
            deck
            ;
          user_oidc = pkgs.fetchNextcloudApp {
            appName = "user_oidc";
            appVersion = "0.8.2";
            license = "agpl3Plus";
            url = "https://github.com/nextcloud-releases/user_oidc/releases/download/v8.10.1/user_oidc-v8.10.1.tar.gz";
            sha256 = "sha256-Sc7R/hkjAvRUC4aUOLbMucoNabcXt27XB1pwqlz2Zv0=";
          };
        };
        settings = {
          trusted_domains = [
            "10.0.10.1"
            "nextcloud.dprive.fr"
          ];
          default_phone_region = "FR";
        };
        configureRedis = true;
      };

      nginx = {
        enable = true;
        virtualHosts."nextcloud.dprive.fr" = {
          useACMEHost = "nextcloud.dprive.fr";
          forceSSL = true;
          locations."~ \.php(?:$|/)".extraConfig = ''
            fastcgi_pass unix:/run/phpfpm-nextcloud.sock;
          '';
        };
      };
    };

    systemd = {
      tmpfiles.rules = [
        "d ${data_dir}/ 0750 nextcloud nextcloud -"
        "d ${data_dir}/config 0750 nextcloud nextcloud -"
        "d ${data_dir}/data 0750 nextcloud nextcloud -"
      ];
      services = {
        "systemd-tmpfiles-setup" = {
          after = [ "mnt-nas-nextcloud.mount" ];
          requires = [ "mnt-nas-nextcloud.mount" ];
        };
        "nextcloud-setup" = {
          after = [
            "postgresql.service"
            "mnt-nas-nextcloud.mount"
          ];
          requires = [
            "postgresql.service"
            "mnt-nas-nextcloud.mount"
          ];
        };
      };
    };
  };
}
