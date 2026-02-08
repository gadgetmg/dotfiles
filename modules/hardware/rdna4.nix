{inputs, ...}: {
  flake.modules.nixos.rdna4 = {
    imports = [
      inputs.nixos-hardware.nixosModules.common-gpu-amd
    ];

    nixpkgs.config.rocmSupport = true;
  };
}
