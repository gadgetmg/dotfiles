{
  flake.modules.nixos.docker = _: {
    virtualisation.docker = {
      enable = true;
      autoPrune.enable = true;
    };

    users.users."matt".extraGroups = ["docker"];
  };
}
