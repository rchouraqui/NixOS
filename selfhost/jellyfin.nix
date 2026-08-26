{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.selfhost.jellyfin;
  data_dir = "/mnt/nas/jellyfin";
in
{
  config = lib.mkIf cfg {
    fileSystems."/mnt/nas/jellyfin" = {
      device = "10.0.10.3:/mnt/HDD/jellyfin-media";
      fsType = "nfs";
      options = [ "nfsvers=4.2" "_netdev" ];
    };
    age.secrets."mullvad-wireguard-secret" = {
      file = ../secrets/mullvad-wireguard-secret.age;
      owner = "root";
      group = "root";
      mode = "0400";
    };
    virtualisation = {
      docker.enable = true;
      oci-containers = {
        backend = "docker";
        containers = {
          gluetun = {
            image = "qmcgaw/gluetun:latest";
            autoStart = true;
            extraOptions = [
              "--cap-add=NET_ADMIN"
              "--device=/dev/net/tun"
              "--dns=8.8.8.8"
              "--dns=1.1.1.1"
            ];
            environmentFiles = [
              config.age.secrets."mullvad-wireguard-secret".path
            ];
            environment = {
              VPN_SERVICE_PROVIDER = "mullvad";
              VPN_TYPE = "wireguard";
              BLOCK_MALICIOUS = "off";
              BLOCK_SURVEILLANCE = "off";
              BLOCK_ADS = "off";
              WIREGUARD_ADDRESSES = "10.68.237.139/32";
              SERVER_COUNTRIES = "Sweden";
              SERVER_CITIES = "Stockholm";
              SERVER_HOSTNAMES = "se-sto-wg-205";
              TZ = "Europe/Paris";
              DNS_ADDRESS = "10.64.0.1";
              DNS_KEEP_NAMESERVER = "off";
            };
            ports = [
              "8080:8080"
              "7878:7878"
              "8989:8989"
              "9696:9696"
            ];
          };
          qbittorrent = {
            image = "lscr.io/linuxserver/qbittorrent:latest";
            autoStart = true;
            dependsOn = [
              "gluetun"
            ];
            extraOptions = [
              "--network=container:gluetun"
            ];
            environment = {
              PUID = "1000";
              PGID = "991";
              WEBUI_PORT = "8080";
              TZ = "Europe/Paris";
            };
            volumes = [
              "${data_dir}/qbittorrent/config:/config"
              "${data_dir}/downloads:/downloads"
            ];
          };
          radarr = {
            image = "lscr.io/linuxserver/radarr:latest";
            autoStart = true;
            dependsOn = [
              "gluetun"
            ];
            extraOptions = [
              "--network=container:gluetun"
            ];
            environment = {
              PUID = "1000";
              PGID = "991";
              TZ = "Europe/Paris";
            };
            volumes = [
              "${data_dir}/radarr/config:/config"
              "${data_dir}/downloads:/downloads"
              "${data_dir}:/data"
            ];
          };
          sonarr = {
            image = "lscr.io/linuxserver/sonarr:latest";
            autoStart = true;
            dependsOn = [
              "gluetun"
            ];
            extraOptions = [
              "--network=container:gluetun"
            ];
            environment = {
              PUID = "1000";
              PGID = "991";
              TZ = "Europe/Paris";
            };
            volumes = [
              "${data_dir}/sonarr/config:/config"
              "${data_dir}/downloads:/downloads"
              "${data_dir}:/data"
            ];
          };
          prowlarr = {
            image = "lscr.io/linuxserver/prowlarr:latest";
            autoStart = true;
            dependsOn = [
              "gluetun"
            ];
            extraOptions = [
              "--network=container:gluetun"
            ];
            environment = {
              PUID = "1000";
              PGID = "991";
              TZ = "Europe/Paris";
            };
            volumes = [
              "${data_dir}/prowlarr/config:/config"
            ];
          };
        };
      };
    };
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          intel-vaapi-driver
          intel-media-driver
          libvdpau-va-gl
          libva
          libva-utils
          vdpauinfo
        ];
      };
    };
    environment = {
      systemPackages = with pkgs; [
        intel-vaapi-driver
        intel-media-driver
        libva
        libva-utils
        ffmpeg-full
        jellyfin-ffmpeg
        vdpauinfo
        nvtopPackages.full
      ];
    };

    users = {
      groups.datausers = { };
      users = {
        jellyfin.extraGroups = [
          "datausers"
          "video"
          "render"
        ];
      };
    };

    services = {
      jellyfin = {
        enable = true;
        dataDir = "${data_dir}/jellyfin";
        cacheDir = "${data_dir}/jellyfin/cache";
        openFirewall = true;
      };

      nginx = {
        enable = true;
        virtualHosts = {
          "jellyfin.dprive.fr" = {
            useACMEHost = "jellyfin.dprive.fr";
            forceSSL = true;
            locations."/" = {
              proxyPass = "http://127.0.0.1:8096";
            };
          };
          "radarr.dprive.fr" = {
            useACMEHost = "radarr.dprive.fr";
            forceSSL = true;
            locations."/" = {
              proxyPass = "http://127.0.0.1:7878";
            };
          };
          "sonarr.dprive.fr" = {
            useACMEHost = "sonarr.dprive.fr";
            forceSSL = true;
            locations."/" = {
              proxyPass = "http://127.0.0.1:8989";
            };
          };
        };
      };
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    systemd = {
      services = {
        jellyfin = {
          after = [
            "network-online.target"
          ];
          unitConfig = {
            RequiresMountsFor = [
              "${data_dir}/movies"
              "${data_dir}/jellyfin/config"
              "${data_dir}/jellyfin/log"
            ];
          };
        };

        update-arr-containers = {
          script = ''
            containers=(gluetun qbittorrent prowlarr sonarr radarr)

            for container in "''${containers[@]}"; do
              image=$(${pkgs.docker}/bin/docker inspect --format='{{.Config.Image}}' "$container")
              echo "Pulling $image..."
              ${pkgs.docker}/bin/docker pull "$image"
            done

            for container in "''${containers[@]}"; do
              echo "Restarting $container..."
              systemctl restart "docker-$container.service"
              sleep 2
            done
          '';
          serviceConfig.Type = "oneshot";
        };
      };

      timers.update-arr-containers = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
          RandomizedDelaySec = "5min";
        };
      };

      tmpfiles.rules = [
        "d ${data_dir} 2770 root datausers -"
        "d ${data_dir}/downloads 0770 jellyfin datausers -"
        "d ${data_dir}/downloads/radarr 0770 jellyfin datausers -"
        "d ${data_dir}/downloads/tv-sonarr 0770 jellyfin datausers -"
        "d ${data_dir}/jellyfin 0770 jellyfin datausers -"
        "d ${data_dir}/jellyfin/config 0770 jellyfin datausers -"
        "d ${data_dir}/jellyfin/cache 0770 jellyfin datausers -"
        "d ${data_dir}/jellyfin/log 0770 jellyfin datausers -"
      ];
    };
  };
}
