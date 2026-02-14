{inputs, ...}: {
  flake.modules.nixos.zen3 = {pkgs, ...}: {
    imports = [
      inputs.nixos-hardware.nixosModules.common-cpu-amd
      inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    ];

    boot.kernelPackages = with pkgs; cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;
    hardware.cpu.amd.ryzen-smu.enable = true;
  };
}
