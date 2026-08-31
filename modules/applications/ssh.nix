{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.applications.ssh;
  sshKeyFramework = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF+94jQUGWbqrlRL/OBlurEbs5ttgu+3V0fadvM6WAIi raph@framework";
  sshKeyMac = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIWcpcUpzbzDQsz/NCdvjXRcSwE75Jw7Clia9m7aPdKV raph@MacBookPro.lan";
  sshKeyMacOcto = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIErXNxFKP0hiG9Y2roysRYNFP9RCPhwhm45ed7MDrQmH raphael.chouraqui@AMAMW9Y2F0YFK";
in

{
  config = lib.mkIf cfg {
    users.users.raph.openssh.authorizedKeys.keys = [
      sshKeyMac
      sshKeyFramework
      sshKeyMacOcto
    ];

    services.openssh = {
      enable = true;
      ports = [ 23305 ];
      openFirewall = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = [ "raph" ];
        MaxAuthTries = 3;
        MaxSessions = 5;
        ClientAliveInterval = 300;
        ClientAliveCountMax = 2;
      };
    };
    networking.firewall.allowedTCPPorts = [
      23305
    ];
  };
}
