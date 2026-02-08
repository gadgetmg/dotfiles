{inputs, ...}: {
  flake.modules.nixos.msi-b450i-gaming-plus-ac = {
    imports = [
      inputs.nixos-hardware.nixosModules.common-pc
    ];

    boot.kernelModules = ["nct6775"];
  };
}
