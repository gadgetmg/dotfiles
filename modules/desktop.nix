{
  flake.modules.nixos.desktop = _: {
    boot.initrd.systemd.enable = true;

    hardware = {
      bluetooth.enable = true;
      enableAllFirmware = true;
    };

    services = {
      earlyoom.enable = true;
      resolved.enable = true;
      logind.settings.Login.KillUserProcesses = true;
    };

    systemd.user.extraConfig = "DefaultTimeoutStopSec=10s";

    networking.networkmanager.enable = true;

    users.users."matt".extraGroups = ["networkmanager"];
  };
}
