{
  flake.modules.nixos.power = _: {
    services.logind.settings.Login = {
      HandlePowerKey = "suspend";
      IdleAction = "suspend";
      IdleActionSec = 300;
    };
  };
}
