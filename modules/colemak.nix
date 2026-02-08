{
  flake.modules.nixos.colemak = {
    console.keyMap = "colemak";

    environment.variables = {
      XKB_DEFAULT_LAYOUT = "us";
      XKB_DEFAULT_VARIANT = "colemak";
    };
  };
}
