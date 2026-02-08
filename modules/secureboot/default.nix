{inputs, ...}: {
  flake.modules.nixos.secureboot = {
    imports = [
      inputs.sops-nix.nixosModules.sops
      inputs.lanzaboote.nixosModules.lanzaboote
    ];

    sops.secrets = let
      secret = name: attrs:
        {
          sopsFile = ./secrets.yaml;
          path = "/var/lib/sbctl/${name}";
        }
        // attrs;
    in {
      "secureboot/keys/db/db.key" = secret "keys/db/db.key" {};
      "secureboot/keys/db/db.pem" = secret "keys/db/db.pem" {};
      "secureboot/keys/KEK/KEK.key" = secret "keys/KEK/KEK.key" {};
      "secureboot/keys/KEK/KEK.pem" = secret "keys/KEK/KEK.pem" {};
      "secureboot/keys/PK/PK.key" = secret "keys/PK/PK.key" {};
      "secureboot/keys/PK/PK.pem" = secret "keys/PK/PK.pem" {};
      "secureboot/GUID" = secret "GUID" {mode = "644";};
    };

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
  };
}
