{
  flake.modules.nixos.snapshots = {
    config,
    lib,
    ...
  }: {
    services.snapper = {
      snapshotInterval = "hourly";
      configs = let
        defaults = {
          FSTYPE = "btrfs";
          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;
          TIMELINE_LIMIT_HOURLY = 24;
          TIMELINE_LIMIT_DAILY = 0;
          TIMELINE_LIMIT_WEEKLY = 0;
          TIMELINE_LIMIT_MONTHLY = 0;
          TIMELINE_LIMIT_QUARTERLY = 0;
          TIMELINE_LIMIT_YEARLY = 0;
        };
        mkIfEnabled = name: mount:
          lib.optionalAttrs (config.fileSystems.${mount}.enable or false)
          {
            ${name} = defaults // {SUBVOLUME = mount;};
          };
      in
        mkIfEnabled "root" "/"
        // mkIfEnabled "home" "/home"
        // mkIfEnabled "steam" "/opt/steam"
        // mkIfEnabled "heroic" "/opt/heroic"
        // mkIfEnabled "roms" "/opt/roms";
    };
  };
}
