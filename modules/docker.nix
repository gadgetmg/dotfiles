{
  flake.modules.nixos.docker = {
    virtualisation.docker = {
      enable = true;
      autoPrune.enable = true;
    };

    users.users."matt".extraGroups = ["docker"];
  };
}
