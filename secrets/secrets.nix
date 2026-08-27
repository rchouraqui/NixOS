let
  framework = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGgR92yn3ANd1n1s+jbGRM/+Y1iV7GEYh2fDLLp+8PdL root@nixos-framework";
  server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEx39A/Xig4JtGkkFi/RoId3xwHhk5wPx4YVGwjmwOMr root@server";

  systems = [
    framework
    server
  ];

in
{
  "cloudflare-token.age".publicKeys = systems;
  "mullvad-wireguard-secret.age".publicKeys = systems;
}
