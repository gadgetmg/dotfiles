{
  flake.modules.nixos.colemak = _: {
    console.keyMap = "colemak";

    environment.variables = {
      XKB_DEFAULT_LAYOUT = "us,us";
      XKB_DEFAULT_VARIANT = "colemak,";
    };

    services.kmscon.extraConfig = ''
      xkb-layout=us,us
      xkb-variant=colemak,
    '';
  };
}
