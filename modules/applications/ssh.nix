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
  sshKeyLinuxOcto = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJAE8chUw9RgCQGYoUes5hEQMEzHydT1Xf+8l0bzjVE raphael-chouraqui@PF5YQH4T";
  sshKeyFix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAhFu3wBDlzs0GZ8aQcs1auH3oBNV0CPzy8kwXN6C32k raph@fix";
in

{
  config = lib.mkIf cfg {
    users.users.raph.openssh.authorizedKeys.keys = [
      sshKeyMac
      sshKeyFramework
      sshKeyLinuxOcto
      sshKeyFix
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
