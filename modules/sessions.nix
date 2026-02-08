{
  flake.modules.nixos.sessions = {
    services.logind.settings.Login.KillUserProcesses = true;
    systemd.user.extraConfig = "DefaultTimeoutStopSec=10s";
  };
}
