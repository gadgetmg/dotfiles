{
  flake.modules.nixos.snapshots = {
    config,
    lib,
    ...
  }: {
    services.snapper = {
      snapshotInterval = "minutely";
      configs = let
        defaults = {
          FSTYPE = "btrfs";
          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;
          TIMELINE_LIMIT_HOURLY = 48;
          TIMELINE_LIMIT_DAILY = 7;
        };
        mkIfEnabled = name: mount:
          lib.optionalAttrs config.fileSystems.${mount}.enable
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
