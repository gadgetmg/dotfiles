{inputs, ...}: {
  flake.modules.nixos.backups = {
    config,
    lib,
    ...
  }: {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    sops.secrets."restic.env" = {
      sopsFile = ./secrets.yaml;
    };

    services.restic.backups.nas = {
      timerConfig = {
        OnCalendar = "05:00";
        Persistent = true;
        WakeSystem = true;
      };
      runCheck = true;
      repository = "s3:https://truenas.lan.seigra.net:9000/restic/${config.networking.hostName}";
      paths =
        ["/" "/home"]
        ++ lib.optional config.fileSystems."/opt/steam".enable "/opt/steam/steamapps/compatdata"
        ++ lib.optional config.fileSystems."/opt/roms".enable "/opt/roms";
      extraBackupArgs = ["--verbose" "--one-file-system"];
      inhibitsSleep = true;
      environmentFile = "/run/secrets/restic.env";
      pruneOpts = ["--keep-daily 7"];
    };
  };
}
