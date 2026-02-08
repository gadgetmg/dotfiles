{inputs, ...}: {
  flake.modules.nixos.openweathermap = {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    sops = {
      secrets = {
        "openweathermap.env" = {
          sopsFile = ./secrets.yaml;
          group = "users";
          mode = "440";
        };
      };
    };
  };
}
