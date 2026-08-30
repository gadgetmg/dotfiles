{
  flake.modules.nixos.power = _: {
    services.logind.settings.Login = {
      HandlePowerKey = "ignore";
      IdleAction = "ignore";
      IdleActionSec = 300;
    };
  };
}
