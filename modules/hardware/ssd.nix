{inputs, ...}: {
  flake.modules.nixos.ssd = {
    imports = [
      inputs.nixos-hardware.nixosModules.common-pc-ssd
    ];
  };
}
