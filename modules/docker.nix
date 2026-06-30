{
  flake.modules.nixos.docker = _: {
    virtualisation.podman = {
      enable = true;
      autoPrune.enable = true;
      dockerSocket.enable = true;
      dockerCompat = true;
    };
    users.users.containers = {
      isSystemUser = true;
      autoSubUidGidRange = true;
      group = "containers";
    };
    users.groups.containers = {};
    users.users."matt".extraGroups = ["podman"];
  };
}
