{inputs, ...}: {
  flake.modules.nixos.ssd = _: {
    imports = [
      inputs.nixos-hardware.nixosModules.common-pc-ssd
    ];
  };
}
