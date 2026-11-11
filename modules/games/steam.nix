{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.games.steam;
in
{
  config = lib.mkIf cfg {
    programs = {
      steam = {
        enable = true;
        package = pkgs.steam.override { extraArgs = "-pipewire"; };
        gamescopeSession.enable = true;
        remotePlay.openFirewall = true;
        extraCompatPackages = with pkgs; [
          protonup-ng
          proton-ge-bin
        ];
      };
      gamemode.enable = true;
    };

    environment.systemPackages = with pkgs; [
      gamescope
      wine-staging
      dxvk
      vkd3d
    ];

    users = {
      groups.datausers = { };
      users = {
        raph.extraGroups = [ "datausers" ];
      };
    };

    systemd.tmpfiles.rules = [
      "d /mnt/data 2770 root datausers -"
    ];

    services = {
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };
    };
  };
}
