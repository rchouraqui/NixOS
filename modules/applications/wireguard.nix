{
  config,
  pkgs,
  lib,
  ...
}:

let
  wireguard-privateKeyFile = config.age.secrets."wireguard-privateKeyFile".path;
  wireguard-presharedKeyFile = config.age.secrets."wireguard-presharedKeyFile".path;
  cfg = config.applications.wireguard;
in
{
  config = lib.mkIf cfg {
    age.secrets."wireguard-privateKeyFile" = {
      file = ../../secrets/wireguard-privateKeyFile.age;
      owner = "root";
      group = "root";
      mode = "0400";
    };
    age.secrets."wireguard-presharedKeyFile" = {
      file = ../../secrets/wireguard-presharedKeyFile.age;
      owner = "root";
      group = "root";
      mode = "0400";
    };

    networking.firewall.allowedUDPPorts = [ 51555 ];

    environment.systemPackages = [ pkgs.wireguard-tools ];

    networking.wg-quick.interfaces = {
      wg0 = {
        autostart = false;
        address = [ "10.0.99.2/32" ];
        privateKeyFile = wireguard-privateKeyFile;

        peers = [
          {
            publicKey = "YHMyzjTOmLJnnxLHQMVP9bYxIKeRdb2SvaAJ6oFtt14=";
            presharedKeyFile = wireguard-presharedKeyFile;
            allowedIPs = [
              "10.0.10.0/24"
              "10.0.20.0/24"
              "10.0.30.0/24"
              "10.0.99.0/29"
            ];
            endpoint = "176.163.160.117:51555";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
