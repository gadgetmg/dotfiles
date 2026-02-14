{
  flake.modules.nixos.btrfs = _: {
    services.btrfs.autoScrub.enable = true;
  };
}
