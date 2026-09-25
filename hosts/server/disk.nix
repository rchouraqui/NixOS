{
  disko.devices = {
    disk = {
      disk1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST1000VX000-1ES162_Z4YE6NNE";
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "rpool";
            };
          };
        };
      };
      disk2 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST1000DM003-1SB10C_Z9A10DN6";
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "rpool";
            };
          };
        };
      };
      disk3 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST1000VX000-1ES162_Z4YE6R0Y";
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "rpool";
            };
          };
        };
      };
      disk4 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST1000DM003-9YN162_S1D3T6Q7";
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "rpool";
            };
          };
        };
      };
    };
    zpool = {
      rpool = {
        type = "zpool";
        mode = "raidz1";
        options = {
          ashift = "12";
        };
        rootFsOptions = {
          compression = "lz4";
          "com.sun:auto-snapshot" = "false";
        };
        datasets = {
          data = {
            type = "zfs_fs";
            mountpoint = "/mnt/disks";
            options.mountpoint = "legacy";
          };
        };
      };
    };
  };
  boot = {
    kernelModules = [ "zfs" ];
    supportedFilesystems = {
      zfs = true;
    };
  };
}
