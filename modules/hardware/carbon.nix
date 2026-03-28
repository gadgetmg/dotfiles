{inputs, ...}: {
  flake.modules.nixos.carbon = _: {
    imports = [
      inputs.self.modules.nixos.msi-b450i-gaming-plus-ac
      inputs.self.modules.nixos.zen3
      inputs.self.modules.nixos.rdna4
      inputs.self.modules.nixos.ssd
      inputs.disko.nixosModules.disko
    ];
    nixpkgs.hostPlatform = "x86_64-linux";
    networking = {
      hostName = "carbon";
      interfaces = {
        enp37s0.wakeOnLan.enable = true;
        enp44s0.wakeOnLan.enable = true;
      };
    };
    time.timeZone = "America/New_York";
    system.stateVersion = "24.11";
    fileSystems = {
      "/home/matt/.local/share/Steam/steamapps" = {
        fsType = "none";
        device = "/opt/steam/steamapps";
        options = ["bind"];
      };
      "/home/matt/Games/Heroic" = {
        fsType = "none";
        device = "/opt/heroic";
        options = ["bind"];
      };
      "/home/matt/Games/ROMs" = {
        fsType = "none";
        device = "/opt/roms";
        options = ["bind"];
      };
    };
    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = "/dev/nvme0n1";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "512M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = ["umask=0077"];
                };
              };
              luks = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "luksroot";
                  settings.allowDiscards = true;
                  content = {
                    type = "btrfs";
                    extraArgs = ["-f"];
                    subvolumes = {
                      "@root" = {
                        mountpoint = "/";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "@home" = {
                        mountpoint = "/home";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "@steam" = {
                        mountpoint = "/opt/steam";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "@heroic" = {
                        mountpoint = "/opt/heroic";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "@roms" = {
                        mountpoint = "/opt/roms";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "@nix" = {
                        mountpoint = "/nix";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "@log" = {
                        mountpoint = "/var/log";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "@swap" = {
                        mountpoint = "/.swapvol";
                        swap.swapfile.size = "32G";
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
    systemd.tmpfiles.rules = [
      # Type Path        Mode    UID     GID     Age  Argument
      "d /opt            0755    0       0       -    -"
      "d /opt/steam      0777    0       100     -    -"
      "d /opt/heroic     0777    0       100     -    -"
      "d /opt/roms       0777    0       100     -    -"
    ];
    fileSystems."/var/log".neededForBoot = true;
    virtualisation.docker.storageDriver = "btrfs";
  };
}
