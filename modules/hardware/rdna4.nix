{inputs, ...}: {
  flake.modules.nixos.rdna4 = _: {
    imports = [
      inputs.nixos-hardware.nixosModules.common-gpu-amd
    ];
  };
}
