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
    age.secrets."scholarsome-secrets" = {
      file = ../secrets/scholarsome-secrets.age;
      owner = "root";
      group = "root";
      mode = "0400";
    };

    virtualisation = {
      docker.enable = true;
      oci-containers = {
        backend = "docker";
        containers = {
          redis = {
            image = "redis:latest";
            autoStart = true;
            extraOptions = [
              "--network=scholarsome-net"
              "--network-alias=redis"
            ];
            cmd = [
              "sh"
              "-c"
              ''
                exec redis-server \
                  --save 900 1 \
                  --appendonly yes \
                  --appendfilename appendonly.aof \
                  --dir /data \
                  --requirepass "$REDIS_PASSWORD"
              ''
            ];
            environmentFiles = [
              config.age.secrets."scholarsome-secrets".path
            ];
            volumes = [
              "${data_dir}/redis/data:/data"
            ];
          };
          mariadb = {
            image = "mariadb:latest";
            autoStart = true;
            extraOptions = [
              "--network=scholarsome-net"
              "--network-alias=mariadb"
            ];
            environmentFiles = [
              config.age.secrets."scholarsome-secrets".path
            ];
            environment = {
              MARIADB_RANDOM_ROOT_PASSWORD = "yes";
              MARIADB_ROOT_HOST = "localhost";
              MARIADB_DATABASE = "scholarsome";
              MARIADB_USER = "scholarsome";
            };
            volumes = [
              "${data_dir}/mariadb:/var/lib/mysql"
            ];
          };
          scholarsome = {
            image = "hwgilbert16/scholarsome:latest";
            autoStart = true;
            extraOptions = [
              "--network=scholarsome-net"
            ];
            dependsOn = [
              "redis"
              "mariadb"
            ];
            ports = [
              "127.0.0.1:3000:3000"
            ];
            environmentFiles = [
              config.age.secrets."scholarsome-secrets".path
            ];
            environment = {
              NODE_ENV = "production";
              HTTP_PORT = "3000";
              STORAGE_TYPE = "local";
              STORAGE_LOCAL_DIR = "/data";
              HOST = "https://flashcards.dprive.fr";
              REDIS_HOST = "redis";
              REDIS_PORT = "6379";
              REDIS_USERNAME = "";
            };
            volumes = [
              "${data_dir}/scholarsome/data:/data"
            ];
          };
        };
      };
    };

    systemd.services = {
      init-scholarsome-network = {
        description = "Créer le réseau Docker scholarsome-net";
        after = [ "docker.service" ];
        requires = [ "docker.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "oneshot";
        script = ''
          ${pkgs.docker}/bin/docker network inspect scholarsome-net >/dev/null 2>&1 || \
          ${pkgs.docker}/bin/docker network create scholarsome-net
        '';
      };

      "docker-redis".after = [ "init-scholarsome-network.service" ];
      "docker-redis".requires = [ "init-scholarsome-network.service" ];
      "docker-mariadb".after = [ "init-scholarsome-network.service" ];
      "docker-mariadb".requires = [ "init-scholarsome-network.service" ];
      "docker-scholarsome".after = [ "init-scholarsome-network.service" ];
      "docker-scholarsome".requires = [ "init-scholarsome-network.service" ];
    };

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
