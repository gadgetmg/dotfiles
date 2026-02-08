{
  flake.modules.nixos.power = {
    services.logind.settings.Login = {
      HandlePowerKey = "suspend";
      IdleAction = "suspend";
      IdleActionSec = 300;
    };
  };
}
