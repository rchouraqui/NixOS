let
  srv-nuc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF8h0U5Dbp8NxS79xv4VSbDt8lS0GbA8R2Uvjy6CL1dk root@srv-nuc";
  #add srv-fix = 
  framework = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGgR92yn3ANd1n1s+jbGRM/+Y1iV7GEYh2fDLLp+8PdL root@nixos-framework";

  systems = [
    srv-nuc
    framework
  ];

in
{
  "cloudflare-token.age".publicKeys = systems;
  "mullvad-wireguard-secret.age".publicKeys = systems;
}
